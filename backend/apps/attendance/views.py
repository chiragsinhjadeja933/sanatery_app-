from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db import transaction
from django.db.models import Sum, Count, Q
from django.utils import timezone
from datetime import datetime, date
from decimal import Decimal

from apps.core.permissions import IsSupervisorOrAbove, IsManagerOrAdmin, IsAdminRole
from apps.staff.models import Staff
from .models import Attendance
from .serializers import (
    AttendanceSerializer,
    AttendanceCreateUpdateSerializer,
    BulkAttendanceSubmissionSerializer
)

class AttendanceViewSet(viewsets.ModelViewSet):
    """
    Attendance CRUD ViewSet.
    - Full search and filtering by date, month, year, staff, department, status.
    - Bulk marking for mobile roster view.
    - Daily summary KPI calculations.
    """
    queryset = Attendance.objects.select_related('staff', 'staff__department').all().order_by('-date', 'staff__employee_code')
    permission_classes = [IsSupervisorOrAbove]

    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return AttendanceCreateUpdateSerializer
        return AttendanceSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        
        # Date filter (exact YYYY-MM-DD)
        date_param = self.request.query_params.get('date')
        if date_param:
            qs = qs.filter(date=date_param)

        # Month and Year filter
        month_param = self.request.query_params.get('month')
        if month_param:
            qs = qs.filter(date__month=month_param)
            
        year_param = self.request.query_params.get('year')
        if year_param:
            qs = qs.filter(date__year=year_param)

        # Staff filter
        staff_id = self.request.query_params.get('staff')
        if staff_id:
            qs = qs.filter(staff_id=staff_id)

        # Department filter
        dept_id = self.request.query_params.get('department')
        if dept_id:
            qs = qs.filter(staff__department_id=dept_id)

        # Status filter
        status_param = self.request.query_params.get('status')
        if status_param:
            qs = qs.filter(status=status_param.upper())

        return qs

    @action(detail=False, methods=['get'])
    def summary(self, request):
        """
        Returns attendance summary metrics for a given date (default: today).
        """
        date_str = request.query_params.get('date')
        if date_str:
            try:
                target_date = datetime.strptime(date_str, '%Y-%m-%d').date()
            except ValueError:
                return Response({"detail": "Invalid date format. Use YYYY-MM-DD."}, status=status.HTTP_400_BAD_REQUEST)
        else:
            target_date = timezone.localdate()

        total_active_staff = Staff.objects.filter(status=Staff.Status.ACTIVE).count()
        records = Attendance.objects.filter(date=target_date)

        present_count = records.filter(status=Attendance.Status.PRESENT).count()
        half_day_count = records.filter(status=Attendance.Status.HALF_DAY).count()
        absent_count = records.filter(status=Attendance.Status.ABSENT).count()
        leave_count = records.filter(status=Attendance.Status.LEAVE).count()
        total_ot_hours = records.aggregate(total_ot=Sum('overtime_hours'))['total_ot'] or Decimal('0.00')

        unmarked_count = max(0, total_active_staff - records.count())

        return Response({
            "date": target_date.strftime('%Y-%m-%d'),
            "total_active_staff": total_active_staff,
            "present_count": present_count,
            "half_day_count": half_day_count,
            "absent_count": absent_count,
            "leave_count": leave_count,
            "unmarked_count": unmarked_count,
            "total_overtime_hours": float(total_ot_hours),
        })

    @action(detail=False, methods=['get'])
    def daily_roster(self, request):
        """
        Returns all active staff alongside their attendance status for a target date.
        Perfect for the mobile Daily Attendance Sheet.
        """
        date_str = request.query_params.get('date')
        if date_str:
            try:
                target_date = datetime.strptime(date_str, '%Y-%m-%d').date()
            except ValueError:
                return Response({"detail": "Invalid date format. Use YYYY-MM-DD."}, status=status.HTTP_400_BAD_REQUEST)
        else:
            target_date = timezone.localdate()

        dept_id = request.query_params.get('department')
        staff_qs = Staff.objects.filter(status=Staff.Status.ACTIVE).select_related('department', 'shift')
        if dept_id:
            staff_qs = staff_qs.filter(department_id=dept_id)

        attendances = {
            att.staff_id: att 
            for att in Attendance.objects.filter(date=target_date)
        }

        roster_data = []
        for member in staff_qs:
            att = attendances.get(member.id)
            roster_data.append({
                "staff_id": member.id,
                "employee_code": member.employee_code,
                "full_name": member.full_name,
                "department_id": member.department_id,
                "department_name": member.department.name,
                "shift_name": member.shift.name if member.shift else 'None',
                "overtime_rate": str(member.overtime_rate),
                "is_marked": att is not None,
                "attendance_id": att.id if att else None,
                "status": att.status if att else None,
                "overtime_hours": str(att.overtime_hours) if att else "0.00",
                "remarks": att.remarks if att else "",
            })

        return Response({
            "date": target_date.strftime('%Y-%m-%d'),
            "total_members": len(roster_data),
            "roster": roster_data
        })

    @action(detail=False, methods=['post'])
    def bulk_mark(self, request):
        """
        Marks or updates attendance for multiple employees atomically for a date.
        Uses high-performance bulk_update and bulk_create with audit lock checks.
        """
        serializer = BulkAttendanceSubmissionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        target_date = serializer.validated_data['date']
        items = serializer.validated_data['attendances']
        staff_ids = [item['staff_id'] for item in items]

        # Audit Check: Verify if payroll has already been finalized for any employee in this month
        from apps.payroll.models import Payroll
        finalized_staff = list(
            Payroll.objects.filter(
                staff_id__in=staff_ids,
                month=target_date.month,
                year=target_date.year,
                status=Payroll.Status.FINALIZED
            ).values_list('staff__employee_code', flat=True)
        )
        if finalized_staff:
            return Response({
                "detail": f"Attendance cannot be modified. Payroll for {target_date.strftime('%B %Y')} is already finalized for: {', '.join(finalized_staff)}."
            }, status=status.HTTP_400_BAD_REQUEST)

        with transaction.atomic():
            existing_records = {
                att.staff_id: att
                for att in Attendance.objects.filter(date=target_date, staff_id__in=staff_ids)
            }

            to_create = []
            to_update = []

            for item in items:
                staff_id = item['staff_id']
                status_val = item['status']
                ot_hours = item.get('overtime_hours', Decimal('0.00'))
                remarks = item.get('remarks', '')

                if staff_id in existing_records:
                    rec = existing_records[staff_id]
                    rec.status = status_val
                    rec.overtime_hours = ot_hours
                    rec.remarks = remarks
                    to_update.append(rec)
                else:
                    to_create.append(
                        Attendance(
                            staff_id=staff_id,
                            date=target_date,
                            status=status_val,
                            overtime_hours=ot_hours,
                            remarks=remarks
                        )
                    )

            if to_update:
                Attendance.objects.bulk_update(to_update, ['status', 'overtime_hours', 'remarks'])
            if to_create:
                Attendance.objects.bulk_create(to_create)

            saved_count = len(to_update) + len(to_create)

        return Response({
            "success": True,
            "message": f"Successfully recorded attendance for {saved_count} staff members on {target_date}.",
            "date": target_date.strftime('%Y-%m-%d'),
            "saved_count": saved_count
        })

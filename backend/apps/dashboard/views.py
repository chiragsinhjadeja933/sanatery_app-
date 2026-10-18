from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions
from django.utils import timezone
from django.db.models import Sum, Count
from decimal import Decimal

from apps.staff.models import Staff
from apps.departments.models import Department
from apps.shifts.models import Shift
from apps.attendance.models import Attendance
from apps.payroll.models import Payroll
from apps.advances.models import AdvanceSalary

class DashboardKPIView(APIView):
    """
    Returns aggregated factory KPIs for the mobile dashboard.
    Accessible by all authenticated roles (Admin, Manager, Supervisor).
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        today = timezone.localdate()
        current_month = today.month
        current_year = today.year

        # 1. Staff and Factory counts
        total_active_staff = Staff.objects.filter(status=Staff.Status.ACTIVE).count()
        total_inactive_staff = Staff.objects.filter(status=Staff.Status.INACTIVE).count()
        total_departments = Department.objects.filter(is_active=True).count()
        total_shifts = Shift.objects.filter(is_active=True).count()

        # 2. Today's Attendance breakdown
        today_records = Attendance.objects.filter(date=today)
        present_today = today_records.filter(status=Attendance.Status.PRESENT).count()
        half_day_today = today_records.filter(status=Attendance.Status.HALF_DAY).count()
        absent_today = today_records.filter(status=Attendance.Status.ABSENT).count()
        leave_today = today_records.filter(status=Attendance.Status.LEAVE).count()
        today_ot_hours = today_records.aggregate(total_ot=Sum('overtime_hours'))['total_ot'] or Decimal('0.00')
        unmarked_today = max(0, total_active_staff - today_records.count())

        # 3. Monthly Payroll snapshot
        monthly_payrolls = Payroll.objects.filter(month=current_month, year=current_year)
        draft_payroll_count = monthly_payrolls.filter(status=Payroll.Status.DRAFT).count()
        finalized_payroll_count = monthly_payrolls.filter(status=Payroll.Status.FINALIZED).count()
        total_net_payroll = monthly_payrolls.aggregate(total=Sum('net_salary'))['total'] or Decimal('0.00')

        # 4. Monthly Advances
        monthly_advances = AdvanceSalary.objects.filter(date__month=current_month, date__year=current_year)
        total_advances_disbursed = monthly_advances.aggregate(total=Sum('amount'))['total'] or Decimal('0.00')

        return Response({
            "factory_overview": {
                "total_active_staff": total_active_staff,
                "total_inactive_staff": total_inactive_staff,
                "total_departments": total_departments,
                "total_shifts": total_shifts,
            },
            "today_attendance": {
                "date": today.strftime('%Y-%m-%d'),
                "present": present_today,
                "half_day": half_day_today,
                "absent": absent_today,
                "leave": leave_today,
                "unmarked": unmarked_today,
                "total_overtime_hours": float(today_ot_hours),
            },
            "current_month_payroll": {
                "month": current_month,
                "year": current_year,
                "draft_count": draft_payroll_count,
                "finalized_count": finalized_payroll_count,
                "total_net_salary": float(total_net_payroll),
                "total_advances_disbursed": float(total_advances_disbursed),
            }
        })

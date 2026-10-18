from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Sum, Count, Q
from django.utils import timezone
from apps.core.permissions import IsAdminRole, IsManagerOrAdmin
from .models import Payroll
from .services import PayrollCalculator
from .serializers import (
    PayrollListSerializer,
    PayrollDetailSerializer,
    PayrollGenerateRequestSerializer
)

class PayrollViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Payroll ViewSet.
    - Admins and Managers can view payroll lists and payslip details.
    - Admins can generate and finalize monthly payrolls.
    """
    queryset = Payroll.objects.select_related('staff', 'staff__department', 'staff__shift').all().order_by('-year', '-month', 'staff__employee_code')
    permission_classes = [IsManagerOrAdmin]

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return PayrollDetailSerializer
        return PayrollListSerializer

    def get_queryset(self):
        qs = super().get_queryset()

        month = self.request.query_params.get('month')
        if month:
            qs = qs.filter(month=month)

        year = self.request.query_params.get('year')
        if year:
            qs = qs.filter(year=year)

        staff_id = self.request.query_params.get('staff')
        if staff_id:
            qs = qs.filter(staff_id=staff_id)

        dept_id = self.request.query_params.get('department')
        if dept_id:
            qs = qs.filter(staff__department_id=dept_id)

        status_param = self.request.query_params.get('status')
        if status_param:
            qs = qs.filter(status=status_param.upper())

        return qs

    @action(detail=False, methods=['post'], permission_classes=[IsAdminRole])
    def generate(self, request):
        """
        Generates or recalculates draft monthly payrolls for staff.
        """
        serializer = PayrollGenerateRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        month = serializer.validated_data['month']
        year = serializer.validated_data['year']
        dept_id = serializer.validated_data.get('department_id')

        generated, skipped = PayrollCalculator.generate_monthly_payroll(
            month=month,
            year=year,
            department_id=dept_id
        )

        message = f"Successfully generated/updated {len(generated)} payroll records for {month:02d}/{year}."
        if skipped:
            message += f" {len(skipped)} finalized records were protected and skipped."

        return Response({
            "success": True,
            "message": message,
            "generated_count": len(generated),
            "skipped_count": len(skipped),
            "skipped_employees": skipped,
            "data": PayrollListSerializer(generated, many=True).data
        })

    @action(detail=True, methods=['post'], permission_classes=[IsAdminRole])
    def finalize(self, request, pk=None):
        """
        Finalizes an individual payroll record.
        """
        payroll = self.get_object()
        if payroll.is_finalized:
            return Response({
                "success": False,
                "message": "This payroll record is already finalized.",
                "data": PayrollDetailSerializer(payroll).data
            }, status=status.HTTP_400_BAD_REQUEST)

        finalized_payroll = PayrollCalculator.finalize_payroll_record(payroll)
        return Response({
            "success": True,
            "message": f"Payroll for {payroll.staff.full_name} for {payroll.month:02d}/{payroll.year} finalized successfully.",
            "data": PayrollDetailSerializer(finalized_payroll).data
        })

    @action(detail=False, methods=['post'], permission_classes=[IsAdminRole])
    def finalize_all(self, request):
        """
        Bulk finalizes all DRAFT payrolls for a given month and year.
        """
        serializer = PayrollGenerateRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        month = serializer.validated_data['month']
        year = serializer.validated_data['year']
        dept_id = serializer.validated_data.get('department_id')

        qs = Payroll.objects.filter(month=month, year=year, status=Payroll.Status.DRAFT)
        if dept_id:
            qs = qs.filter(staff__department_id=dept_id)

        count = 0
        for payroll in qs:
            PayrollCalculator.finalize_payroll_record(payroll)
            count += 1

        return Response({
            "success": True,
            "message": f"Finalized {count} payroll records for {month:02d}/{year}.",
            "finalized_count": count
        })

    @action(detail=False, methods=['get'])
    def summary(self, request):
        """
        Aggregated monthly payroll totals and status distribution.
        """
        now = timezone.localdate()
        month = request.query_params.get('month', now.month)
        year = request.query_params.get('year', now.year)

        payrolls = Payroll.objects.filter(month=month, year=year)

        total_net = payrolls.aggregate(total=Sum('net_salary'))['total'] or 0.00
        total_gross = payrolls.aggregate(total=Sum('gross_salary'))['total'] or 0.00
        total_advances = payrolls.aggregate(total=Sum('advance_deduction'))['total'] or 0.00
        total_ot_amount = payrolls.aggregate(total=Sum('overtime_amount'))['total'] or 0.00

        draft_count = payrolls.filter(status=Payroll.Status.DRAFT).count()
        finalized_count = payrolls.filter(status=Payroll.Status.FINALIZED).count()

        return Response({
            "month": int(month),
            "year": int(year),
            "total_records": payrolls.count(),
            "draft_count": draft_count,
            "finalized_count": finalized_count,
            "total_net_salary": float(total_net),
            "total_gross_salary": float(total_gross),
            "total_advance_deductions": float(total_advances),
            "total_overtime_amount": float(total_ot_amount),
        })

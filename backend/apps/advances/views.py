from rest_framework import viewsets, permissions
from apps.core.permissions import IsManagerOrAdmin
from .models import AdvanceSalary
from .serializers import (
    AdvanceSalarySerializer,
    AdvanceSalaryCreateUpdateSerializer
)

class AdvanceSalaryViewSet(viewsets.ModelViewSet):
    """
    Advance Salary CRUD ViewSet.
    - Managers and Admins can create and manage advance records.
    - Filter by staff, month, year, status.
    """
    queryset = AdvanceSalary.objects.select_related('staff', 'staff__department').all().order_by('-date')
    permission_classes = [IsManagerOrAdmin]

    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return AdvanceSalaryCreateUpdateSerializer
        return AdvanceSalarySerializer

    def get_queryset(self):
        qs = super().get_queryset()
        
        staff_id = self.request.query_params.get('staff')
        if staff_id:
            qs = qs.filter(staff_id=staff_id)

        month = self.request.query_params.get('month')
        if month:
            qs = qs.filter(date__month=month)

        year = self.request.query_params.get('year')
        if year:
            qs = qs.filter(date__year=year)

        status_param = self.request.query_params.get('status')
        if status_param:
            qs = qs.filter(status=status_param.upper())

        return qs

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        if instance.status == AdvanceSalary.Status.DEDUCTED:
            from rest_framework.exceptions import ValidationError
            raise ValidationError("This advance salary has already been deducted in payroll and cannot be edited.")
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        if instance.status == AdvanceSalary.Status.DEDUCTED:
            from rest_framework.exceptions import ValidationError
            raise ValidationError("This advance salary has already been deducted in payroll and cannot be deleted.")
        return super().destroy(request, *args, **kwargs)

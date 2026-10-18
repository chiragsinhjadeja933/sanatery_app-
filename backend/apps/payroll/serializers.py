from rest_framework import serializers
from .models import Payroll
from apps.staff.serializers import StaffDetailSerializer

class PayrollListSerializer(serializers.ModelSerializer):
    employee_code = serializers.CharField(source='staff.employee_code', read_only=True)
    staff_name = serializers.CharField(source='staff.full_name', read_only=True)
    department_name = serializers.CharField(source='staff.department.name', read_only=True)
    designation = serializers.CharField(source='staff.designation', read_only=True)

    class Meta:
        model = Payroll
        fields = [
            'id', 'staff', 'employee_code', 'staff_name', 'department_name',
            'designation', 'month', 'year', 'base_salary', 'paid_days',
            'overtime_hours', 'overtime_amount', 'gross_salary',
            'advance_deduction', 'net_salary', 'status',
            'generated_at', 'finalized_at'
        ]

class PayrollDetailSerializer(serializers.ModelSerializer):
    employee_code = serializers.CharField(source='staff.employee_code', read_only=True)
    staff_name = serializers.CharField(source='staff.full_name', read_only=True)
    phone = serializers.CharField(source='staff.phone', read_only=True)
    department_name = serializers.CharField(source='staff.department.name', read_only=True)
    designation = serializers.CharField(source='staff.designation', read_only=True)
    shift_name = serializers.CharField(source='staff.shift.name', read_only=True, allow_null=True)
    base_payable = serializers.DecimalField(max_digits=12, decimal_places=2, read_only=True)

    class Meta:
        model = Payroll
        fields = [
            'id', 'staff', 'employee_code', 'staff_name', 'phone',
            'department_name', 'designation', 'shift_name',
            'month', 'year', 'base_salary', 'payroll_days', 'paid_days',
            'base_payable', 'attendance_deduction', 'overtime_hours',
            'overtime_rate', 'overtime_amount', 'gross_salary',
            'advance_deduction', 'other_deductions', 'net_salary',
            'status', 'generated_at', 'finalized_at'
        ]

class PayrollGenerateRequestSerializer(serializers.Serializer):
    month = serializers.IntegerField(min_value=1, max_value=12)
    year = serializers.IntegerField(min_value=2000, max_value=2100)
    department_id = serializers.IntegerField(required=False, allow_null=True)

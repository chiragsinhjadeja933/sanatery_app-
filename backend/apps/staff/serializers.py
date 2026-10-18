from rest_framework import serializers
from decimal import Decimal
from apps.departments.serializers import DepartmentSerializer
from apps.shifts.serializers import ShiftSerializer
from apps.departments.models import Department
from apps.shifts.models import Shift
from .models import Staff

class StaffListSerializer(serializers.ModelSerializer):
    department_name = serializers.CharField(source='department.name', read_only=True)
    shift_name = serializers.CharField(source='shift.name', read_only=True, allow_null=True)
    shift_hours = serializers.DecimalField(max_digits=5, decimal_places=2, read_only=True)
    daily_salary = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    hourly_salary = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    standard_ot_rate_1_5x = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = Staff
        fields = [
            'id', 'employee_code', 'full_name', 'phone', 'joining_date',
            'department', 'department_name', 'designation',
            'shift', 'shift_name', 'shift_hours', 'salary_type', 'monthly_salary',
            'overtime_rate', 'daily_salary', 'hourly_salary', 'standard_ot_rate_1_5x',
            'status', 'created_at', 'updated_at'
        ]

class StaffDetailSerializer(serializers.ModelSerializer):
    department_detail = DepartmentSerializer(source='department', read_only=True)
    shift_detail = ShiftSerializer(source='shift', read_only=True)
    shift_hours = serializers.DecimalField(max_digits=5, decimal_places=2, read_only=True)
    daily_salary = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    hourly_salary = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    standard_ot_rate_1_5x = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = Staff
        fields = [
            'id', 'employee_code', 'full_name', 'phone', 'joining_date',
            'department', 'department_detail', 'designation',
            'shift', 'shift_detail', 'shift_hours', 'salary_type', 'monthly_salary',
            'overtime_rate', 'daily_salary', 'hourly_salary', 'standard_ot_rate_1_5x',
            'status', 'created_at', 'updated_at'
        ]

class StaffCreateUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Staff
        fields = [
            'id', 'employee_code', 'full_name', 'phone', 'joining_date',
            'department', 'designation', 'shift', 'salary_type',
            'monthly_salary', 'overtime_rate', 'status'
        ]

    def validate_monthly_salary(self, value):
        if value < Decimal('0'):
            raise serializers.ValidationError("Monthly salary cannot be negative.")
        return value

    def validate_overtime_rate(self, value):
        if value < Decimal('0'):
            raise serializers.ValidationError("Overtime rate cannot be negative.")
        return value

    def validate(self, attrs):
        user = self.context['request'].user
        # Only Admin can set/change salary and overtime rate
        if self.instance and not (user.is_superuser or user.role == 'ADMIN'):
            if 'monthly_salary' in attrs and attrs['monthly_salary'] != self.instance.monthly_salary:
                raise serializers.ValidationError({"monthly_salary": "Only Admins can modify employee salary."})
            if 'overtime_rate' in attrs and attrs['overtime_rate'] != self.instance.overtime_rate:
                raise serializers.ValidationError({"overtime_rate": "Only Admins can modify overtime rate."})
        return attrs

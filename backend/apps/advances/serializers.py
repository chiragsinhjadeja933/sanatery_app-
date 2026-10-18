from rest_framework import serializers
from decimal import Decimal
from .models import AdvanceSalary

class AdvanceSalarySerializer(serializers.ModelSerializer):
    employee_code = serializers.CharField(source='staff.employee_code', read_only=True)
    staff_name = serializers.CharField(source='staff.full_name', read_only=True)
    department_name = serializers.CharField(source='staff.department.name', read_only=True)

    class Meta:
        model = AdvanceSalary
        fields = [
            'id', 'staff', 'employee_code', 'staff_name', 'department_name',
            'amount', 'date', 'reason', 'status', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

class AdvanceSalaryCreateUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = AdvanceSalary
        fields = ['id', 'staff', 'amount', 'date', 'reason', 'status']
        read_only_fields = ['id']

    def validate_amount(self, value):
        if value <= Decimal('0'):
            raise serializers.ValidationError("Advance amount must be greater than zero.")
        return value

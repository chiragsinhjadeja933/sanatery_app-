from rest_framework import serializers
from decimal import Decimal
from apps.staff.serializers import StaffListSerializer
from .models import Attendance
from apps.staff.models import Staff

class AttendanceSerializer(serializers.ModelSerializer):
    employee_code = serializers.CharField(source='staff.employee_code', read_only=True)
    staff_name = serializers.CharField(source='staff.full_name', read_only=True)
    department_name = serializers.CharField(source='staff.department.name', read_only=True)
    overtime_rate = serializers.DecimalField(source='staff.overtime_rate', max_digits=10, decimal_places=2, read_only=True)
    overtime_amount = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    paid_day_weight = serializers.DecimalField(max_digits=3, decimal_places=1, read_only=True)

    class Meta:
        model = Attendance
        fields = [
            'id', 'staff', 'employee_code', 'staff_name', 'department_name',
            'date', 'status', 'overtime_hours', 'overtime_rate', 'overtime_amount',
            'paid_day_weight', 'remarks', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

class AttendanceCreateUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Attendance
        fields = ['id', 'staff', 'date', 'status', 'overtime_hours', 'remarks']
        read_only_fields = ['id']

    def validate_overtime_hours(self, value):
        if value < Decimal('0') or value > Decimal('12'):
            raise serializers.ValidationError("Overtime hours must be between 0.00 and 12.00.")
        return value

        # Check if payroll for this staff & month is already finalized
        if staff and date:
            from apps.payroll.models import Payroll
            if Payroll.objects.filter(staff=staff, month=date.month, year=date.year, status=Payroll.Status.FINALIZED).exists():
                raise serializers.ValidationError({
                    "non_field_errors": [f"Attendance for {date.strftime('%B %Y')} is locked. Payroll has already been finalized."]
                })

        # Check uniqueness if creating new or changing date/staff
        if self.instance is None and staff and date:
            if Attendance.objects.filter(staff=staff, date=date).exists():
                raise serializers.ValidationError({
                    "non_field_errors": [f"Attendance for {staff.full_name} ({staff.employee_code}) on {date} already exists."]
                })
        return attrs

class BulkAttendanceItemSerializer(serializers.Serializer):
    staff_id = serializers.IntegerField()
    status = serializers.ChoiceField(choices=Attendance.Status.choices, default=Attendance.Status.PRESENT)
    overtime_hours = serializers.DecimalField(max_digits=4, decimal_places=2, default=Decimal('0.00'))
    remarks = serializers.CharField(max_length=255, required=False, allow_blank=True, default='')

class BulkAttendanceSubmissionSerializer(serializers.Serializer):
    date = serializers.DateField()
    attendances = BulkAttendanceItemSerializer(many=True)

from rest_framework import serializers
from .models import Department

class DepartmentSerializer(serializers.ModelSerializer):
    staff_count = serializers.SerializerMethodField()

    class Meta:
        model = Department
        fields = ['id', 'name', 'description', 'is_active', 'staff_count', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_staff_count(self, obj):
        # Count active staff belonging to this department
        return getattr(obj, 'active_staff_count', obj.staff_members.filter(status='ACTIVE').count())

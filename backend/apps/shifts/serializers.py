from rest_framework import serializers
from .models import Shift

class ShiftSerializer(serializers.ModelSerializer):
    formatted_time = serializers.SerializerMethodField()

    class Meta:
        model = Shift
        fields = ['id', 'name', 'start_time', 'end_time', 'duration_hours', 'formatted_time', 'is_active', 'created_at', 'updated_at']
        read_only_fields = ['id', 'duration_hours', 'created_at', 'updated_at']

    def get_formatted_time(self, obj):
        return f"{obj.start_time.strftime('%H:%M')} - {obj.end_time.strftime('%H:%M')}"

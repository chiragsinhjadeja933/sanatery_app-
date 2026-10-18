from django.contrib import admin
from .models import Attendance

@admin.register(Attendance)
class AttendanceAdmin(admin.ModelAdmin):
    list_display = ('staff', 'date', 'status', 'overtime_hours', 'created_at')
    list_filter = ('status', 'date', 'staff__department')
    search_fields = ('staff__employee_code', 'staff__full_name')
    date_hierarchy = 'date'

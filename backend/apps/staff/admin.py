from django.contrib import admin
from .models import Staff

@admin.register(Staff)
class StaffAdmin(admin.ModelAdmin):
    list_display = ('employee_code', 'full_name', 'department', 'designation', 'monthly_salary', 'overtime_rate', 'status')
    search_fields = ('employee_code', 'full_name', 'phone')
    list_filter = ('department', 'shift', 'status', 'salary_type')

from django.contrib import admin
from .models import AdvanceSalary

@admin.register(AdvanceSalary)
class AdvanceSalaryAdmin(admin.ModelAdmin):
    list_display = ('staff', 'amount', 'date', 'status', 'created_at')
    list_filter = ('status', 'date')
    search_fields = ('staff__employee_code', 'staff__full_name', 'reason')

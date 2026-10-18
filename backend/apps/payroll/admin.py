from django.contrib import admin
from .models import Payroll

@admin.register(Payroll)
class PayrollAdmin(admin.ModelAdmin):
    list_display = ('staff', 'month', 'year', 'paid_days', 'gross_salary', 'net_salary', 'status')
    list_filter = ('status', 'year', 'month', 'staff__department')
    search_fields = ('staff__employee_code', 'staff__full_name')

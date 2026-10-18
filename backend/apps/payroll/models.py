from django.db import models
from django.core.exceptions import ValidationError
from decimal import Decimal
from apps.core.models import TimeStampedModel
from apps.staff.models import Staff

class Payroll(TimeStampedModel):
    class Status(models.TextChoices):
        DRAFT = 'DRAFT', 'Draft'
        FINALIZED = 'FINALIZED', 'Finalized'

    staff = models.ForeignKey(
        Staff, 
        on_delete=models.PROTECT, 
        related_name='payrolls'
    )
    month = models.SmallIntegerField(help_text="Payroll month (1-12).")
    year = models.SmallIntegerField(help_text="Payroll year (e.g. 2026).")
    
    # Financial snapshot fields
    base_salary = models.DecimalField(
        max_digits=12, 
        decimal_places=2,
        help_text="Snapshot of monthly base salary at generation time."
    )
    payroll_days = models.DecimalField(
        max_digits=4, 
        decimal_places=2, 
        default=Decimal('30.00'),
        help_text="Standard payroll days in month (usually 30.00)."
    )
    paid_days = models.DecimalField(
        max_digits=4, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Calculated paid days (Present + 0.5 * HalfDay)."
    )
    attendance_deduction = models.DecimalField(
        max_digits=12, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Deduction for unpaid/absent days."
    )
    overtime_hours = models.DecimalField(
        max_digits=6, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Total overtime hours worked in month."
    )
    overtime_rate = models.DecimalField(
        max_digits=10, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Snapshot of overtime hourly rate."
    )
    overtime_amount = models.DecimalField(
        max_digits=12, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Total overtime pay (hours * rate)."
    )
    gross_salary = models.DecimalField(
        max_digits=12, 
        decimal_places=2,
        help_text="Gross salary = Base Salary + Overtime Amount."
    )
    advance_deduction = models.DecimalField(
        max_digits=12, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Total salary advances deducted this month."
    )
    other_deductions = models.DecimalField(
        max_digits=12, 
        decimal_places=2, 
        default=Decimal('0.00')
    )
    net_salary = models.DecimalField(
        max_digits=12, 
        decimal_places=2,
        help_text="Final payable salary = Base Payable + OT - Advances."
    )
    status = models.CharField(
        max_length=20, 
        choices=Status.choices, 
        default=Status.DRAFT
    )
    generated_at = models.DateTimeField(auto_now_add=True)
    finalized_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'payroll'
        ordering = ['-year', '-month', 'staff__employee_code']
        constraints = [
            models.UniqueConstraint(
                fields=['staff', 'month', 'year'],
                name='unique_staff_month_year_payroll'
            ),
            models.CheckConstraint(
                condition=models.Q(base_salary__gte=0),
                name='payroll_base_salary_non_negative'
            ),
            models.CheckConstraint(
                condition=models.Q(net_salary__gte=0),
                name='payroll_net_salary_non_negative'
            ),
            models.CheckConstraint(
                condition=models.Q(paid_days__gte=0) & models.Q(paid_days__lte=31),
                name='payroll_paid_days_range'
            ),
            models.CheckConstraint(
                condition=models.Q(month__gte=1) & models.Q(month__lte=12),
                name='payroll_month_valid_range'
            ),
        ]
        indexes = [
            models.Index(fields=['month', 'year']),
            models.Index(fields=['staff', 'month', 'year']),
            models.Index(fields=['status']),
        ]

    def __str__(self):
        return f"{self.staff.employee_code} - {self.month:02d}/{self.year} (₹{self.net_salary} - {self.status})"

    @property
    def is_finalized(self):
        return self.status == self.Status.FINALIZED

    @property
    def base_payable(self):
        """Amount payable before overtime and advances."""
        daily_rate = (self.base_salary / self.payroll_days).quantize(Decimal('0.01'))
        return (self.paid_days * daily_rate).quantize(Decimal('0.01'))

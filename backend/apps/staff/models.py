from django.db import models
from django.core.exceptions import ValidationError
from decimal import Decimal
from apps.core.models import TimeStampedModel
from apps.departments.models import Department
from apps.shifts.models import Shift

class Staff(TimeStampedModel):
    class Status(models.TextChoices):
        ACTIVE = 'ACTIVE', 'Active'
        INACTIVE = 'INACTIVE', 'Inactive'

    class SalaryType(models.TextChoices):
        MONTHLY = 'MONTHLY', 'Monthly'

    employee_code = models.CharField(
        max_length=30, 
        unique=True, 
        db_index=True,
        help_text="Unique Employee ID / Code (e.g. STF001)."
    )
    full_name = models.CharField(max_length=150)
    phone = models.CharField(max_length=20)
    joining_date = models.DateField()
    department = models.ForeignKey(
        Department, 
        on_delete=models.PROTECT, 
        related_name='staff_members'
    )
    designation = models.CharField(max_length=100)
    shift = models.ForeignKey(
        Shift, 
        on_delete=models.PROTECT, 
        null=True, 
        blank=True, 
        related_name='staff_members'
    )
    salary_type = models.CharField(
        max_length=20, 
        choices=SalaryType.choices, 
        default=SalaryType.MONTHLY
    )
    monthly_salary = models.DecimalField(
        max_digits=12, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Base monthly salary in currency units."
    )
    overtime_rate = models.DecimalField(
        max_digits=10, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Overtime rate per hour in currency units."
    )
    status = models.CharField(
        max_length=20, 
        choices=Status.choices, 
        default=Status.ACTIVE,
        db_index=True
    )

    class Meta:
        db_table = 'staff'
        ordering = ['employee_code']
        constraints = [
            models.CheckConstraint(
                condition=models.Q(monthly_salary__gte=0),
                name='staff_monthly_salary_non_negative'
            ),
            models.CheckConstraint(
                condition=models.Q(overtime_rate__gte=0),
                name='staff_overtime_rate_non_negative'
            ),
        ]

    def clean(self):
        super().clean()
        if self.monthly_salary < 0:
            raise ValidationError({'monthly_salary': 'Monthly salary cannot be negative.'})
        if self.overtime_rate < 0:
            raise ValidationError({'overtime_rate': 'Overtime rate cannot be negative.'})

    def save(self, *args, **kwargs):
        # Auto-compute 1.5x regular 1-hour wage if overtime_rate is 0.00
        if (not self.overtime_rate or self.overtime_rate == Decimal('0.00')) and self.monthly_salary > 0:
            self.overtime_rate = self.standard_ot_rate_1_5x
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.full_name} ({self.employee_code}) - {self.department.name}"

    @property
    def daily_salary(self):
        """Standard 30-day daily salary assumption."""
        return (self.monthly_salary / Decimal('30')).quantize(Decimal('0.01'))

    @property
    def shift_hours(self):
        """Dynamic shift duration from assigned shift, with fallback to 8.00 if unassigned."""
        if self.shift and self.shift.duration_hours > 0:
            return self.shift.duration_hours
        return Decimal('8.00')

    @property
    def hourly_salary(self):
        """Calculates hourly rate dynamically based on specific shift hours."""
        return (self.daily_salary / self.shift_hours).quantize(Decimal('0.01'))

    @property
    def standard_ot_rate_1_5x(self):
        """Overtime rate calculated as 1.5x regular 1-hour rate."""
        return (self.hourly_salary * Decimal('1.5')).quantize(Decimal('0.01'))

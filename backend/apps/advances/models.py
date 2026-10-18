from django.db import models
from django.core.exceptions import ValidationError
from decimal import Decimal
from apps.core.models import TimeStampedModel
from apps.staff.models import Staff

class AdvanceSalary(TimeStampedModel):
    class Status(models.TextChoices):
        APPROVED = 'APPROVED', 'Approved'
        DEDUCTED = 'DEDUCTED', 'Deducted in Payroll'
        CANCELLED = 'CANCELLED', 'Cancelled'

    staff = models.ForeignKey(
        Staff, 
        on_delete=models.PROTECT, 
        related_name='advances'
    )
    amount = models.DecimalField(
        max_digits=12, 
        decimal_places=2,
        help_text="Advance amount disbursed."
    )
    date = models.DateField(help_text="Date advance was given.")
    reason = models.CharField(max_length=255, blank=True, default='', help_text="Reason for advance.")
    status = models.CharField(
        max_length=20, 
        choices=Status.choices, 
        default=Status.APPROVED
    )

    class Meta:
        db_table = 'advances'
        ordering = ['-date']
        constraints = [
            models.CheckConstraint(
                condition=models.Q(amount__gt=0),
                name='advance_amount_positive'
            )
        ]

    def clean(self):
        super().clean()
        if self.amount <= 0:
            raise ValidationError({'amount': 'Advance amount must be greater than zero.'})

    def __str__(self):
        return f"{self.staff.employee_code} - ₹{self.amount} ({self.status})"

from django.db import models
from django.core.exceptions import ValidationError
from decimal import Decimal
from apps.core.models import TimeStampedModel
from apps.staff.models import Staff

class Attendance(TimeStampedModel):
    class Status(models.TextChoices):
        PRESENT = 'PRESENT', 'Present'
        HALF_DAY = 'HALF_DAY', 'Half Day'
        ABSENT = 'ABSENT', 'Absent'
        LEAVE = 'LEAVE', 'Leave'

    staff = models.ForeignKey(
        Staff, 
        on_delete=models.PROTECT, 
        related_name='attendance_records'
    )
    date = models.DateField(db_index=True)
    status = models.CharField(
        max_length=20, 
        choices=Status.choices, 
        default=Status.PRESENT
    )
    overtime_hours = models.DecimalField(
        max_digits=4, 
        decimal_places=2, 
        default=Decimal('0.00'),
        help_text="Overtime hours worked on this day (0.00 to 12.00)."
    )
    remarks = models.CharField(max_length=255, blank=True, default='')

    class Meta:
        db_table = 'attendance'
        ordering = ['-date', 'staff__employee_code']
        constraints = [
            models.UniqueConstraint(
                fields=['staff', 'date'], 
                name='unique_staff_date_attendance'
            ),
            models.CheckConstraint(
                condition=models.Q(overtime_hours__gte=0) & models.Q(overtime_hours__lte=12),
                name='attendance_overtime_hours_range'
            )
        ]
        indexes = [
            models.Index(fields=['date']),
            models.Index(fields=['staff', 'date']),
        ]

    def clean(self):
        super().clean()
        if self.overtime_hours < 0 or self.overtime_hours > 12:
            raise ValidationError({'overtime_hours': 'Overtime hours must be between 0.00 and 12.00.'})

    def __str__(self):
        return f"{self.staff.employee_code} - {self.date} ({self.status})"

    @property
    def paid_day_weight(self):
        if self.status == self.Status.PRESENT:
            return Decimal('1.0')
        elif self.status == self.Status.HALF_DAY:
            return Decimal('0.5')
        return Decimal('0.0')

    @property
    def overtime_amount(self):
        return (self.overtime_hours * self.staff.overtime_rate).quantize(Decimal('0.01'))

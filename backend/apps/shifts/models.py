from django.db import models
from datetime import datetime, date, timedelta
from decimal import Decimal
from apps.core.models import TimeStampedModel

class Shift(TimeStampedModel):
    name = models.CharField(max_length=50, unique=True, help_text="Shift name (e.g. Morning, Evening, Night).")
    start_time = models.TimeField(help_text="Shift start time (e.g. 08:00:00).")
    end_time = models.TimeField(help_text="Shift end time (e.g. 16:00:00).")
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'shifts'
        ordering = ['start_time']

    def __str__(self):
        return f"{self.name} ({self.start_time.strftime('%H:%M')} - {self.end_time.strftime('%H:%M')})"

    @property
    def duration_hours(self):
        """Calculates shift duration in hours, handling overnight/cross-midnight shifts."""
        ref_date = date.today()
        dt_start = datetime.combine(ref_date, self.start_time)
        dt_end = datetime.combine(ref_date, self.end_time)
        if dt_end <= dt_start:
            dt_end += timedelta(days=1)
        seconds = (dt_end - dt_start).total_seconds()
        return Decimal(str(round(seconds / 3600.0, 2)))

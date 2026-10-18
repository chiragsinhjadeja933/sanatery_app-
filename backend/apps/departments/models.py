from django.db import models
from apps.core.models import TimeStampedModel

class Department(TimeStampedModel):
    name = models.CharField(max_length=100, unique=True, help_text="Unique name of the department.")
    description = models.TextField(blank=True, default='')
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'departments'
        ordering = ['name']

    def __str__(self):
        return self.name

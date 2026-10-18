from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    class Role(models.TextChoices):
        ADMIN = 'ADMIN', 'Admin'
        MANAGER = 'MANAGER', 'Manager'
        SUPERVISOR = 'SUPERVISOR', 'Supervisor'

    role = models.CharField(
        max_length=20,
        choices=Role.choices,
        default=Role.SUPERVISOR,
        help_text="Designates the system role and permission level."
    )
    phone = models.CharField(max_length=20, blank=True, default='')

    class Meta:
        db_table = 'users'

    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"

    @property
    def is_admin(self):
        return self.role == self.Role.ADMIN or self.is_superuser

    @property
    def is_manager(self):
        return self.role == self.Role.MANAGER

    @property
    def is_supervisor(self):
        return self.role == self.Role.SUPERVISOR

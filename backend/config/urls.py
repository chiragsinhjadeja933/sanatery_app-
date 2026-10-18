from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # API Endpoints
    path('api/', include('apps.accounts.urls')),
    path('api/', include('apps.departments.urls')),
    path('api/', include('apps.shifts.urls')),
    path('api/', include('apps.staff.urls')),
    path('api/', include('apps.attendance.urls')),
    path('api/', include('apps.advances.urls')),
    path('api/', include('apps.payroll.urls')),
    path('api/', include('apps.dashboard.urls')),
]

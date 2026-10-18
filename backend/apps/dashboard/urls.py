from django.urls import path
from .views import DashboardKPIView

urlpatterns = [
    path('dashboard/', DashboardKPIView.as_view(), name='dashboard_overview'),
    path('dashboard/kpi/', DashboardKPIView.as_view(), name='dashboard_kpi'),
]

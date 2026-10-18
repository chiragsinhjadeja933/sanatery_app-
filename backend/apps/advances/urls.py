from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import AdvanceSalaryViewSet

router = DefaultRouter()
router.register(r'advances', AdvanceSalaryViewSet, basename='advance')

urlpatterns = [
    path('', include(router.urls)),
]

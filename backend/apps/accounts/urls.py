from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from .views import CustomLoginView, CurrentUserView, UserViewSet

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')

urlpatterns = [
    # Auth endpoints (supporting both /auth/login/ and /login/)
    path('auth/login/', CustomLoginView.as_view(), name='auth_login'),
    path('login/', CustomLoginView.as_view(), name='login'),
    
    path('auth/refresh/', TokenRefreshView.as_view(), name='auth_refresh'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    path('auth/me/', CurrentUserView.as_view(), name='auth_me'),
    path('me/', CurrentUserView.as_view(), name='me'),
    
    path('', include(router.urls)),
]

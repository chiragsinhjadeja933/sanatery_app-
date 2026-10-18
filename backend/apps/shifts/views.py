from rest_framework import viewsets, permissions
from apps.core.permissions import IsAdminRole
from .models import Shift
from .serializers import ShiftSerializer

class ShiftViewSet(viewsets.ModelViewSet):
    """
    Shift CRUD ViewSet.
    - All authenticated users can list/retrieve shifts.
    - Only ADMIN can create, update, or delete shifts.
    """
    queryset = Shift.objects.all().order_by('start_time')
    serializer_class = ShiftSerializer

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.IsAuthenticated()]
        return [IsAdminRole()]

    def get_queryset(self):
        qs = super().get_queryset()
        status_param = self.request.query_params.get('is_active')
        if status_param is not None:
            is_active = status_param.lower() in ['true', '1']
            qs = qs.filter(is_active=is_active)
        return qs

from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Q
from django.db.models.deletion import ProtectedError
from apps.core.permissions import IsAdminRole, IsManagerOrAdmin, IsSupervisorOrAbove
from .models import Staff
from .serializers import (
    StaffListSerializer,
    StaffDetailSerializer,
    StaffCreateUpdateSerializer
)

class StaffViewSet(viewsets.ModelViewSet):
    """
    Staff CRUD and Management ViewSet.
    - Search & Filter support (department, shift, status, query)
    - Deactivate / Activate action endpoints
    """
    queryset = Staff.objects.select_related('department', 'shift').all().order_by('employee_code')

    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return StaffCreateUpdateSerializer
        if self.action == 'retrieve':
            return StaffDetailSerializer
        return StaffListSerializer

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.IsAuthenticated()]
        if self.action in ['create', 'update', 'partial_update']:
            return [IsManagerOrAdmin()]
        if self.action in ['destroy', 'deactivate', 'activate']:
            return [IsAdminRole()]
        return [IsAdminRole()]

    def get_queryset(self):
        qs = super().get_queryset()
        
        # Search query across full_name, employee_code, phone, designation
        search = self.request.query_params.get('search', '').strip()
        if search:
            qs = qs.filter(
                Q(full_name__icontains=search) |
                Q(employee_code__icontains=search) |
                Q(phone__icontains=search) |
                Q(designation__icontains=search)
            )

        # Department filter
        department_id = self.request.query_params.get('department')
        if department_id:
            qs = qs.filter(department_id=department_id)

        # Shift filter
        shift_id = self.request.query_params.get('shift')
        if shift_id:
            qs = qs.filter(shift_id=shift_id)

        # Status filter (ACTIVE, INACTIVE)
        status_param = self.request.query_params.get('status')
        if status_param:
            qs = qs.filter(status=status_param.upper())

        return qs

    def destroy(self, request, *args, **kwargs):
        staff = self.get_object()
        try:
            return super().destroy(request, *args, **kwargs)
        except ProtectedError:
            return Response({
                "success": False,
                "message": "Cannot delete staff with historical attendance, advance, or payroll records. Please deactivate instead.",
                "errors": {"detail": "Protected foreign key relation exists."}
            }, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'], permission_classes=[IsAdminRole])
    def deactivate(self, request, pk=None):
        staff = self.get_object()
        staff.status = Staff.Status.INACTIVE
        staff.save(update_fields=['status', 'updated_at'])
        return Response({
            "success": True,
            "message": f"Staff {staff.full_name} ({staff.employee_code}) deactivated successfully.",
            "data": StaffDetailSerializer(staff).data
        })

    @action(detail=True, methods=['post'], permission_classes=[IsAdminRole])
    def activate(self, request, pk=None):
        staff = self.get_object()
        staff.status = Staff.Status.ACTIVE
        staff.save(update_fields=['status', 'updated_at'])
        return Response({
            "success": True,
            "message": f"Staff {staff.full_name} ({staff.employee_code}) activated successfully.",
            "data": StaffDetailSerializer(staff).data
        })

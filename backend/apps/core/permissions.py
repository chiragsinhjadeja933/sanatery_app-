from rest_framework.permissions import BasePermission

class IsAdminRole(BasePermission):
    """
    Allows access only to Admin users.
    """
    def has_permission(self, request, view):
        return bool(
            request.user and 
            request.user.is_authenticated and 
            (request.user.role == 'ADMIN' or request.user.is_superuser)
        )

class IsManagerOrAdmin(BasePermission):
    """
    Allows access to Managers and Admins.
    """
    def has_permission(self, request, view):
        return bool(
            request.user and 
            request.user.is_authenticated and 
            (request.user.role in ['ADMIN', 'MANAGER'] or request.user.is_superuser)
        )

class IsSupervisorOrAbove(BasePermission):
    """
    Allows access to Supervisors, Managers, and Admins.
    """
    def has_permission(self, request, view):
        return bool(
            request.user and 
            request.user.is_authenticated and 
            (request.user.role in ['ADMIN', 'MANAGER', 'SUPERVISOR'] or request.user.is_superuser)
        )

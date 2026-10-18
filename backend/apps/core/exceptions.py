from rest_framework.views import exception_handler
from rest_framework.exceptions import ValidationError, AuthenticationFailed, NotAuthenticated, PermissionDenied
from django.db import IntegrityError
from rest_framework.response import Response
from rest_framework import status

def custom_exception_handler(exc, context):
    """
    Standardized custom exception handler returning consistent JSON responses:
    {
        "success": False,
        "message": "...",
        "errors": { ... }
    }
    """
    response = exception_handler(exc, context)

    if response is not None:
        message = "Validation or request processing error."
        if isinstance(exc, (NotAuthenticated, AuthenticationFailed)):
            message = "Authentication credentials were not provided or are invalid."
        elif isinstance(exc, PermissionDenied):
            message = "You do not have permission to perform this action."
        elif isinstance(exc, ValidationError):
            message = "Input validation failed. Please review your entries."
        
        custom_data = {
            "success": False,
            "message": message,
            "errors": response.data
        }
        response.data = custom_data
        return response

    # Handle database integrity errors gracefully
    if isinstance(exc, IntegrityError):
        err_msg = str(exc)
        user_message = "A database constraint violation occurred."
        if "unique" in err_msg.lower() or "duplicate" in err_msg.lower():
            user_message = "A record with these details already exists."
        
        return Response({
            "success": False,
            "message": user_message,
            "errors": {"detail": str(exc)}
        }, status=status.HTTP_400_BAD_REQUEST)

    return None

from rest_framework.renderers import JSONRenderer

class StandardJSONRenderer(JSONRenderer):
    """
    Ensures all API responses conform to a unified standard structure:
    {
        "success": True,
        "message": "...",
        "data": { ... }
    }
    """
    def render(self, data, accepted_media_type=None, renderer_context=None):
        response = renderer_context.get('response', None) if renderer_context else None
        
        if response is not None:
            # If already structured (e.g. from custom exception handler or custom view), pass through
            if isinstance(data, dict) and ('success' in data or 'errors' in data):
                return super().render(data, accepted_media_type, renderer_context)
            
            status_code = response.status_code
            is_success = 200 <= status_code < 300

            # Default message
            message = "Operation completed successfully." if is_success else "An error occurred."
            
            formatted_data = {
                "success": is_success,
                "message": message,
                "data": data if is_success else None
            }
            if not is_success:
                formatted_data["errors"] = data

            return super().render(formatted_data, accepted_media_type, renderer_context)

        return super().render(data, accepted_media_type, renderer_context)

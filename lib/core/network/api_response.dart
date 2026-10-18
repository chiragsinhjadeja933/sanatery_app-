class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    final success = json['success'] as bool? ?? false;
    final message = json['message'] as String? ?? '';
    final rawData = json['data'];

    T? parsedData;
    if (rawData != null && fromJsonT != null) {
      parsedData = fromJsonT(rawData);
    } else if (rawData != null && rawData is T) {
      parsedData = rawData;
    }

    return ApiResponse<T>(
      success: success,
      message: message,
      data: parsedData,
      errors: json['errors'],
    );
  }

  factory ApiResponse.error(String errorMessage, {dynamic errors}) {
    return ApiResponse<T>(
      success: false,
      message: errorMessage,
      data: null,
      errors: errors,
    );
  }

  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final List<dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.errors,
  });

  @override
  String toString() => message;
}

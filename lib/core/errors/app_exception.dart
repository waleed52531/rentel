enum AppErrorType {
  badRequest,
  network,
  unauthorized,
  forbidden,
  notFound,
  validation,
  conflict,
  unknown
}

class AppException implements Exception {
  const AppException(this.message,
      {this.type = AppErrorType.unknown, this.fieldErrors = const {}});

  final String message;
  final AppErrorType type;
  final Map<String, List<String>> fieldErrors;

  bool get canRetry =>
      type == AppErrorType.network || type == AppErrorType.unknown;

  factory AppException.fromStatusCode(int statusCode,
      {String? message, Map<String, List<String>>? errors}) {
    final type = switch (statusCode) {
      400 => AppErrorType.badRequest,
      401 => AppErrorType.unauthorized,
      403 => AppErrorType.forbidden,
      404 => AppErrorType.notFound,
      409 => AppErrorType.conflict,
      422 => AppErrorType.validation,
      >= 500 => AppErrorType.network,
      _ => AppErrorType.unknown,
    };
    return AppException(message ?? _fallback(type),
        type: type, fieldErrors: errors ?? const {});
  }

  static String _fallback(AppErrorType type) => switch (type) {
        AppErrorType.network => 'Please check your connection and try again.',
        AppErrorType.badRequest => 'The request could not be processed.',
        AppErrorType.unauthorized =>
          'Your session has expired. Please sign in again.',
        AppErrorType.forbidden =>
          'You do not have permission to perform this action.',
        AppErrorType.notFound => 'The requested item could not be found.',
        AppErrorType.validation => 'Please correct the highlighted fields.',
        AppErrorType.conflict =>
          'This action conflicts with the current record state.',
        AppErrorType.unknown => 'Something went wrong. Please try again.',
      };

  @override
  String toString() => message;
}

String readableError(Object error) {
  if (error is AppException) {
    if (error.fieldErrors.isEmpty) return error.message;
    final details = error.fieldErrors.values
        .expand((messages) => messages)
        .toSet()
        .join('\n');
    return details.isEmpty ? error.message : details;
  }
  if (error is StateError) return error.message;
  return 'Something went wrong. Please try again.';
}

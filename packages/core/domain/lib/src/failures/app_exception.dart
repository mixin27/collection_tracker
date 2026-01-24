import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

@freezed
sealed class AppException with _$AppException implements Exception {
  const factory AppException.network({
    required String message,
    @Default('') String details,
    StackTrace? stackTrace,
  }) = NetworkException;

  const factory AppException.timeout({required String message}) =
      TimeoutException;

  const factory AppException.database({
    required String message,
    StackTrace? stackTrace,
  }) = DatabaseException;

  const factory AppException.validation({
    required String message,
    Map<String, String>? fieldErrors,
  }) = ValidationException;

  const factory AppException.notFound({
    required String message,
    String? resourceType,
    String? resourceId,
  }) = NotFoundException;

  const factory AppException.permission({
    required String message,
    required String permissionType,
  }) = PermissionException;

  const factory AppException.business({required String message, String? code}) =
      BusinessException;

  const factory AppException.unknown({
    required String message,
    StackTrace? stackTrace,
  }) = UnknownException;
}

extension AppExceptionX on AppException {
  String get userMessage => when(
    network: (msg, _, _) =>
        'Network error. Please check your connection and try again.',
    timeout: (msg) => 'Request timed out. Please try again.',
    database: (msg, _) => 'A database error occurred. Please try again.',
    validation: (msg, _) => msg,
    notFound: (msg, _, _) => msg,
    permission: (msg, _) => msg,
    business: (msg, _) => msg,
    unknown: (msg, _) => 'An unexpected error occurred. Please try again.',
  );
}

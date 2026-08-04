import 'package:dio/dio.dart';
import 'package:mobile/core/error/failures.dart';

class ErrorMapper {
  static Failure mapDioErrorToFailure(DioException error) {
    if (error.type == DioExceptionType.cancel) {
      return NetworkFailure('Request cancelled.');
    }

    if (error.type == DioExceptionType.connectionTimeout || 
        error.type == DioExceptionType.receiveTimeout || 
        error.type == DioExceptionType.sendTimeout) {
      return NetworkFailure('Connection timed out. Please try again.');
    }

    if (error.type == DioExceptionType.connectionError || error.type == DioExceptionType.unknown) {
      return NetworkFailure('No internet connection or server unreachable.');
    }

    final response = error.response;
    if (response != null) {
      switch (response.statusCode) {
        case 401:
          return ServerFailure('Session expired or invalid credentials.');
        case 403:
          return ServerFailure('You do not have permission to perform this action.');
        case 404:
          return ServerFailure('Resource not found.');
        case 422:
          return ValidationFailure(_parseValidationErrors(response.data));
        case 400:
          final data = response.data;
          if (data is Map && data.containsKey('error_type')) {
            final errorType = data['error_type'];
            if (errorType == 'RELEVANCE_ERROR') {
              return ValidationFailure('Please capture a clear image of a plant leaf.');
            } else if (errorType == 'CROP_MISMATCH') {
              return ValidationFailure('Selected crop does not match the detected plant.');
            } else if (errorType == 'MODEL_MISSING') {
              return ServerFailure('Plant analysis service is temporarily unavailable.');
            }
            return ValidationFailure(data['message'] ?? 'Invalid request.');
          }
          return ValidationFailure(data is Map ? (data['detail'] ?? 'Invalid request.') : 'Invalid request.');
        case 500:
          return ServerFailure('Internal server error.');
        default:
          return ServerFailure('Received invalid status code: ${response.statusCode}');
      }
    }

    return UnknownFailure();
  }

  static String _parseValidationErrors(dynamic responseData) {
    if (responseData is Map && responseData.containsKey('detail')) {
      final detail = responseData['detail'];
      if (detail is List && detail.isNotEmpty) {
        final List<String> errors = [];
        for (var err in detail) {
          if (err is Map) {
            final loc = (err['loc'] as List?)?.last ?? 'Field';
            final msg = err['msg'] ?? 'invalid';
            errors.add('$loc: $msg');
          }
        }
        return errors.join('\n');
      } else if (detail is String) {
        return detail;
      }
    }
    return 'Validation failed.';
  }
}

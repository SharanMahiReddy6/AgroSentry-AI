import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.d(
      'REQUEST[${options.method}] => URL: ${options.uri}\n'
      'HEADERS: ${options.headers}\n'
      'BODY: ${options.data}'
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d(
      'RESPONSE[${response.statusCode}] => URL: ${response.requestOptions.uri}\n'
      'DATA: ${response.data}'
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e(
      'ERROR[${err.response?.statusCode}] => URL: ${err.requestOptions.uri}\n'
      'RESPONSE_DATA: ${err.response?.data}\n'
      'MESSAGE: ${err.message}',
      error: err,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }
}

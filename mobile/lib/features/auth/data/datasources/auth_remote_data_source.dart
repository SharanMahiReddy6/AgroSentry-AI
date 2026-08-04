import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/features/auth/data/models/auth_requests.dart';
import 'package:mobile/features/auth/data/models/auth_responses.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(String email, String password);
  Future<LoginResponse> register(RegisterRequest request);
  Future<GenericAuthResponse> forgotPassword(ForgotPasswordRequest request);
  Future<GenericAuthResponse> verifyOtp(VerifyOtpRequest request);
  Future<GenericAuthResponse> resetPassword(ResetPasswordRequest request);
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<LoginResponse> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'username': email,
        'password': password,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return LoginResponse.fromJson(response.data);
  }

  @override
  Future<LoginResponse> register(RegisterRequest request) async {
    final response = await _dio.post('/auth/register', data: request.toJson());
    return LoginResponse.fromJson(response.data);
  }

  @override
  Future<GenericAuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    final response = await _dio.post('/auth/forgot-password', data: request.toJson());
    return GenericAuthResponse.fromJson(response.data);
  }

  @override
  Future<GenericAuthResponse> verifyOtp(VerifyOtpRequest request) async {
    final response = await _dio.post('/auth/verify-reset-code', data: request.toJson());
    return GenericAuthResponse.fromJson(response.data);
  }

  @override
  Future<GenericAuthResponse> resetPassword(ResetPasswordRequest request) async {
    final response = await _dio.post('/auth/reset-password', data: request.toJson());
    return GenericAuthResponse.fromJson(response.data);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data);
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/error/error_mapper.dart';
import 'package:mobile/core/storage/secure_storage_service.dart';
import 'package:mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mobile/features/auth/data/models/auth_requests.dart';
import 'package:mobile/features/auth/data/models/auth_responses.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageServiceProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorageService;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorageService);

  @override
  Future<void> login(String email, String password) async {
    try {
      final response = await _remoteDataSource.login(email, password);
      await _secureStorageService.saveToken(response.accessToken);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioErrorToFailure(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> register(RegisterRequest request) async {
    try {
      final response = await _remoteDataSource.register(request);
      await _secureStorageService.saveToken(response.accessToken);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioErrorToFailure(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<GenericAuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    try {
      return await _remoteDataSource.forgotPassword(request);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioErrorToFailure(e);
    }
  }

  @override
  Future<GenericAuthResponse> verifyOtp(VerifyOtpRequest request) async {
    try {
      return await _remoteDataSource.verifyOtp(request);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioErrorToFailure(e);
    }
  }

  @override
  Future<GenericAuthResponse> resetPassword(ResetPasswordRequest request) async {
    try {
      return await _remoteDataSource.resetPassword(request);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioErrorToFailure(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      return await _remoteDataSource.getCurrentUser();
    } on DioException catch (e) {
      throw ErrorMapper.mapDioErrorToFailure(e);
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorageService.deleteToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _secureStorageService.getToken();
    return token != null;
  }
}

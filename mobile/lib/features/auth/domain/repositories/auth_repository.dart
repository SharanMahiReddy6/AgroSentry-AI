import 'package:mobile/features/auth/data/models/auth_requests.dart';
import 'package:mobile/features/auth/data/models/auth_responses.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> register(RegisterRequest request);
  Future<GenericAuthResponse> forgotPassword(ForgotPasswordRequest request);
  Future<GenericAuthResponse> verifyOtp(VerifyOtpRequest request);
  Future<GenericAuthResponse> resetPassword(ResetPasswordRequest request);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
  Future<bool> isLoggedIn();
}

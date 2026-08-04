import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/models/auth_requests.dart';
import 'package:mobile/features/auth/data/models/auth_responses.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';

void main() {
  group('Auth Models Serialization', () {
    test('RegisterRequest serializes to correct JSON', () {
      final req = RegisterRequest(
        email: 'test@example.com',
        password: 'Password1!',
        fullName: 'Test User',
      );

      final json = req.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['password'], 'Password1!');
      expect(json['full_name'], 'Test User');
    });

    test('LoginResponse deserializes correctly', () {
      final json = {
        'access_token': 'ey12345',
        'token_type': 'bearer',
      };

      final res = LoginResponse.fromJson(json);

      expect(res.accessToken, 'ey12345');
      expect(res.tokenType, 'bearer');
    });

    test('UserModel deserializes correctly', () {
      final json = {
        'id': 1,
        'email': 'admin@agrosentry.com',
        'full_name': 'Admin',
        'is_admin': true,
        'two_factor_enabled': false,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.email, 'admin@agrosentry.com');
      expect(user.fullName, 'Admin');
      expect(user.isAdmin, true);
      expect(user.twoFactorEnabled, false);
      expect(user.region, isNull);
    });
  });
}

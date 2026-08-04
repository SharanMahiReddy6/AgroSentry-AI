import 'dart:io';
import 'package:mobile/features/auth/data/models/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<UserModel> uploadPhoto(File file);
  Future<UserModel> deletePhoto();
  Future<void> changePassword(String oldPassword, String newPassword);
}

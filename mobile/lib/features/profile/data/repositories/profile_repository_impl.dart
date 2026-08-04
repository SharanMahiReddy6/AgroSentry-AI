import 'dart:io';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mobile/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    return await _remoteDataSource.updateProfile(data);
  }

  @override
  Future<UserModel> uploadPhoto(File file) async {
    return await _remoteDataSource.uploadPhoto(file);
  }

  @override
  Future<UserModel> deletePhoto() async {
    return await _remoteDataSource.deletePhoto();
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _remoteDataSource.changePassword(oldPassword, newPassword);
  }
}

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:http_parser/http_parser.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<UserModel> uploadPhoto(File file);
  Future<UserModel> deletePhoto();
  Future<void> changePassword(String oldPassword, String newPassword);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/auth/me', data: data);
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> uploadPhoto(File file) async {
    String fileName = file.path.split('/').last;
    
    // Create FormData
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: MediaType('image', fileName.split('.').last),
      ),
    });

    final response = await _dio.post('/auth/me/photo', data: formData);
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> deletePhoto() async {
    final response = await _dio.delete('/auth/me/photo');
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.post('/auth/me/password', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }
}

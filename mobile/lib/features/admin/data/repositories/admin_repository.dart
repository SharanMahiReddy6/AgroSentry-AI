import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/features/tips/data/models/quick_tip_model.dart';

class AdminRepository {
  final Dio _dio;
  AdminRepository(this._dio);

  Future<List<dynamic>> getJobs() async {
    final response = await _dio.get('/training/jobs');
    return response.data;
  }

  Future<List<UserModel>> getUsers() async {
    final response = await _dio.get('/auth/users');
    return (response.data as List).map((u) => UserModel.fromJson(u)).toList();
  }

  Future<List<QuickTipModel>> getPendingTips() async {
    final response = await _dio.get('/tips/pending');
    return (response.data as List).map((t) => QuickTipModel.fromJson(t)).toList();
  }

  Future<List<String>> getAvailableDatasets() async {
    final response = await _dio.get('/training/available-datasets');
    return List<String>.from(response.data);
  }

  Future<void> startTraining(String datasetName, int epochs) async {
    await _dio.post('/training/start-local', data: {
      'dataset_name': datasetName,
      'num_epochs': epochs,
    });
  }

  Future<void> uploadDataset(File file, String cropName, bool isFullDataset, String? diseaseName) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
      'crop_name': cropName,
      'is_full_dataset': isFullDataset.toString(),
    });
    if (diseaseName != null && diseaseName.isNotEmpty) {
      formData.fields.add(MapEntry('disease_name', diseaseName));
    }
    await _dio.post('/training/upload-dataset', data: formData);
  }

  Future<void> deployModel(int jobId) async {
    await _dio.post('/training/deploy/$jobId');
  }

  Future<void> approveTip(int tipId) async {
    await _dio.post('/tips/$tipId/approve');
  }

  Future<void> deleteTip(int tipId) async {
    await _dio.delete('/tips/$tipId');
  }

  Future<void> sendNotification(String title, String message, int? userId) async {
    await _dio.post('/notifications', data: {
      'title': title,
      'message': message,
      'user_id': userId,
    });
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(dioClientProvider));
});

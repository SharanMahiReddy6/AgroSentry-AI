import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/features/scan/data/models/scan_result_model.dart';
import 'package:mobile/features/scan/data/models/scan_history_model.dart';

final scanRemoteDataSourceProvider = Provider<ScanRemoteDataSource>((ref) {
  return ScanRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

abstract class ScanRemoteDataSource {
  Future<ScanResultModel> uploadScan(String imagePath, String cropType, CancelToken cancelToken);
  Future<List<ScanHistoryModel>> getHistory(CancelToken cancelToken);
  Future<ScanResultModel> getScanDetails(int scanId, CancelToken cancelToken);
  Future<void> deleteScan(int scanId);
}

class ScanRemoteDataSourceImpl implements ScanRemoteDataSource {
  final Dio _dio;

  ScanRemoteDataSourceImpl(this._dio);

  @override
  Future<ScanResultModel> uploadScan(String imagePath, String cropType, CancelToken cancelToken) async {
    final formData = FormData.fromMap({
      'crop_type': cropType,
      'file': await MultipartFile.fromFile(imagePath),
    });

    final response = await _dio.post(
      '/scans/upload',
      data: formData,
      cancelToken: cancelToken,
      options: Options(
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    return ScanResultModel.fromJson(response.data);
  }

  @override
  Future<List<ScanHistoryModel>> getHistory(CancelToken cancelToken) async {
    final response = await _dio.get('/scans/history', cancelToken: cancelToken);
    final List data = response.data;
    return data.map((json) => ScanHistoryModel.fromJson(json)).toList();
  }

  @override
  Future<ScanResultModel> getScanDetails(int scanId, CancelToken cancelToken) async {
    final response = await _dio.get('/scans/$scanId', cancelToken: cancelToken);
    return ScanResultModel.fromJson(response.data);
  }

  @override
  Future<void> deleteScan(int scanId) async {
    await _dio.delete('/scans/$scanId');
  }
}

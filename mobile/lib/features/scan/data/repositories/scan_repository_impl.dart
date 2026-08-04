import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/error/error_mapper.dart';
import 'package:mobile/features/scan/data/datasources/scan_remote_data_source.dart';
import 'package:mobile/features/scan/data/models/scan_result_model.dart';
import 'package:mobile/features/scan/data/models/scan_history_model.dart';
import 'package:mobile/features/scan/domain/repositories/scan_repository.dart';

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepositoryImpl(ref.watch(scanRemoteDataSourceProvider));
});

class ScanRepositoryImpl implements ScanRepository {
  final ScanRemoteDataSource _remoteDataSource;

  ScanRepositoryImpl(this._remoteDataSource);

  @override
  Future<ScanResultModel> uploadScan(String imagePath, String cropType, CancelToken cancelToken) async {
    try {
      return await _remoteDataSource.uploadScan(imagePath, cropType, cancelToken);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioErrorToFailure(e);
    }
  }

  @override
  Future<List<ScanHistoryModel>> getHistory(CancelToken cancelToken) async {
    try {
      return await _remoteDataSource.getHistory(cancelToken);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioErrorToFailure(e);
    }
  }

  @override
  Future<ScanResultModel> getScanDetails(int scanId, CancelToken cancelToken) async {
    try {
      return await _remoteDataSource.getScanDetails(scanId, cancelToken);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioErrorToFailure(e);
    }
  }

  @override
  Future<void> deleteScan(int scanId) async {
    try {
      await _remoteDataSource.deleteScan(scanId);
    } on DioException catch (e) {
      throw ErrorMapper.mapDioErrorToFailure(e);
    }
  }
}

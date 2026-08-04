import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/error/error_mapper.dart';
import 'package:mobile/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:mobile/features/dashboard/data/models/dashboard_models.dart';
import 'package:mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ScanRecordModel>> getRecentScans() async {
    try {
      return await _remoteDataSource.getRecentScans();
    } on DioException catch (e) {
      throw ErrorMapper.mapDioErrorToFailure(e);
    }
  }

  @override
  Future<List<TipModel>> getQuickTips() async {
    try {
      return await _remoteDataSource.getQuickTips();
    } on DioException catch (e) {
      throw ErrorMapper.mapDioErrorToFailure(e);
    }
  }
}

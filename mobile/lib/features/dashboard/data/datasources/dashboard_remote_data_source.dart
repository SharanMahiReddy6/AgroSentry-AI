import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/features/dashboard/data/models/dashboard_models.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

abstract class DashboardRemoteDataSource {
  Future<List<ScanRecordModel>> getRecentScans();
  Future<List<TipModel>> getQuickTips();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ScanRecordModel>> getRecentScans() async {
    final response = await _dio.get('/scans/history');
    final List<dynamic> data = response.data;
    return data.map((json) => ScanRecordModel.fromJson(json)).toList();
  }

  @override
  Future<List<TipModel>> getQuickTips() async {
    final response = await _dio.get('/tips');
    final List<dynamic> data = response.data;
    return data.map((json) => TipModel.fromJson(json)).toList();
  }
}

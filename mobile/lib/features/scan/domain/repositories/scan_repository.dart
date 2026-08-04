import 'package:dio/dio.dart';
import 'package:mobile/features/scan/data/models/scan_result_model.dart';
import 'package:mobile/features/scan/data/models/scan_history_model.dart';

abstract class ScanRepository {
  Future<ScanResultModel> uploadScan(String imagePath, String cropType, CancelToken cancelToken);
  Future<List<ScanHistoryModel>> getHistory(CancelToken cancelToken);
  Future<ScanResultModel> getScanDetails(int scanId, CancelToken cancelToken);
  Future<void> deleteScan(int scanId);
}

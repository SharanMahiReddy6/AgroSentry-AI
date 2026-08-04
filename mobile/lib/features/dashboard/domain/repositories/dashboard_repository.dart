import 'package:mobile/features/dashboard/data/models/dashboard_models.dart';

abstract class DashboardRepository {
  Future<List<ScanRecordModel>> getRecentScans();
  Future<List<TipModel>> getQuickTips();
}

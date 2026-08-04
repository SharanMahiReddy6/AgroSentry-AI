import 'package:dio/dio.dart';
import 'package:mobile/features/tips/data/models/quick_tip_model.dart';

abstract class TipsRepository {
  Future<List<QuickTipModel>> getTips({CancelToken? cancelToken});
  Future<Map<String, dynamic>> submitTip(Map<String, dynamic> tipData, {CancelToken? cancelToken});
}

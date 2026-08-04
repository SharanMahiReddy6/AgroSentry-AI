import 'package:dio/dio.dart';
import 'package:mobile/features/tips/data/datasources/tips_remote_datasource.dart';
import 'package:mobile/features/tips/data/models/quick_tip_model.dart';
import 'package:mobile/features/tips/domain/repositories/tips_repository.dart';

class TipsRepositoryImpl implements TipsRepository {
  final TipsRemoteDataSource _remoteDataSource;

  TipsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<QuickTipModel>> getTips({CancelToken? cancelToken}) async {
    return await _remoteDataSource.getTips(cancelToken: cancelToken);
  }

  @override
  Future<Map<String, dynamic>> submitTip(Map<String, dynamic> tipData, {CancelToken? cancelToken}) async {
    return await _remoteDataSource.submitTip(tipData, cancelToken: cancelToken);
  }
}

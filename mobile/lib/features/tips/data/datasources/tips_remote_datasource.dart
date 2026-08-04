import 'package:dio/dio.dart';
import 'package:mobile/features/tips/data/models/quick_tip_model.dart';

abstract class TipsRemoteDataSource {
  Future<List<QuickTipModel>> getTips({CancelToken? cancelToken});
  Future<Map<String, dynamic>> submitTip(Map<String, dynamic> tipData, {CancelToken? cancelToken});
}

class TipsRemoteDataSourceImpl implements TipsRemoteDataSource {
  final Dio _dio;

  TipsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<QuickTipModel>> getTips({CancelToken? cancelToken}) async {
    final response = await _dio.get(
      '/tips',
      cancelToken: cancelToken,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => QuickTipModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tips');
    }
  }

  @override
  Future<Map<String, dynamic>> submitTip(Map<String, dynamic> tipData, {CancelToken? cancelToken}) async {
    final response = await _dio.post(
      '/tips/submit',
      data: tipData,
      cancelToken: cancelToken,
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to submit tip');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:mobile/features/library/data/models/library_disease_model.dart';

abstract class LibraryRemoteDataSource {
  Future<List<LibraryDiseaseModel>> getDiseases({CancelToken? cancelToken});
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final Dio _dio;

  LibraryRemoteDataSourceImpl(this._dio);

  @override
  Future<List<LibraryDiseaseModel>> getDiseases({CancelToken? cancelToken}) async {
    final response = await _dio.get(
      '/scans/diseases',
      cancelToken: cancelToken,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      return data.entries.map((entry) {
        return LibraryDiseaseModel.fromJson(entry.key, entry.value as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception('Failed to load diseases');
    }
  }
}

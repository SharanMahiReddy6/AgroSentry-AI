import 'package:dio/dio.dart';
import 'package:mobile/features/library/data/datasources/library_remote_datasource.dart';
import 'package:mobile/features/library/data/models/library_disease_model.dart';
import 'package:mobile/features/library/domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource _remoteDataSource;

  LibraryRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<LibraryDiseaseModel>> getDiseases({CancelToken? cancelToken}) async {
    return await _remoteDataSource.getDiseases(cancelToken: cancelToken);
  }
}

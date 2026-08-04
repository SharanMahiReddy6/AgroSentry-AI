import 'package:dio/dio.dart';
import 'package:mobile/features/library/data/models/library_disease_model.dart';

abstract class LibraryRepository {
  Future<List<LibraryDiseaseModel>> getDiseases({CancelToken? cancelToken});
}

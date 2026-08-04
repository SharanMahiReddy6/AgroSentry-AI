import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/features/library/data/datasources/library_remote_datasource.dart';
import 'package:mobile/features/library/data/models/library_disease_model.dart';
import 'package:mobile/features/library/data/repositories/library_repository_impl.dart';
import 'package:mobile/features/library/domain/repositories/library_repository.dart';
import 'package:mobile/core/network/translation_service.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/library/presentation/providers/library_translation_helper.dart';

final libraryRemoteDataSourceProvider = Provider<LibraryRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return LibraryRemoteDataSourceImpl(dio);
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final remoteDataSource = ref.watch(libraryRemoteDataSourceProvider);
  return LibraryRepositoryImpl(remoteDataSource);
});

final libraryDiseasesProvider = FutureProvider.autoDispose<List<LibraryDiseaseModel>>((ref) async {
  final repository = ref.watch(libraryRepositoryProvider);
  final targetLang = ref.watch(currentUserProvider)?.language ?? 'en';
  final translationService = ref.watch(translationServiceProvider);
  final cancelToken = CancelToken();
  
  ref.onDispose(() {
    cancelToken.cancel();
  });

  // To cache during the session, we keep the state alive
  ref.keepAlive();
  
  final diseases = await repository.getDiseases(cancelToken: cancelToken);
  if (targetLang == 'en') return diseases;
  
  final translated = <LibraryDiseaseModel>[];
  for (final disease in diseases) {
    translated.add(await translateDisease(disease, translationService, targetLang));
  }
  return translated;
});

// Providers for search and filtering
final librarySearchQueryProvider = StateProvider<String>((ref) => '');
final libraryCropFilterProvider = StateProvider<String?>((ref) => null);
final libraryHealthFilterProvider = StateProvider<String?>((ref) => null); // 'Healthy', 'Diseased', null

final filteredLibraryDiseasesProvider = Provider.autoDispose<AsyncValue<List<LibraryDiseaseModel>>>((ref) {
  final diseasesAsync = ref.watch(libraryDiseasesProvider);
  final query = ref.watch(librarySearchQueryProvider).toLowerCase();
  final cropFilter = ref.watch(libraryCropFilterProvider);
  final healthFilter = ref.watch(libraryHealthFilterProvider);

  return diseasesAsync.whenData((diseases) {
    return diseases.where((disease) {
      final matchesQuery = query.isEmpty ||
          disease.name.toLowerCase().contains(query) ||
          disease.scientificName.toLowerCase().contains(query) ||
          disease.cropType.toLowerCase().contains(query);
          
      final matchesCrop = cropFilter == null || disease.cropType == cropFilter;
      
      bool matchesHealth = true;
      if (healthFilter == 'Healthy') {
        matchesHealth = disease.name.toLowerCase().contains('healthy');
      } else if (healthFilter == 'Diseased') {
        matchesHealth = !disease.name.toLowerCase().contains('healthy');
      }
      
      return matchesQuery && matchesCrop && matchesHealth;
    }).toList();
  });
});

final libraryAvailableCropsProvider = Provider.autoDispose<AsyncValue<List<String>>>((ref) {
  final diseasesAsync = ref.watch(libraryDiseasesProvider);
  
  return diseasesAsync.whenData((diseases) {
    final crops = diseases.map((d) => d.cropType).toSet().toList();
    crops.sort();
    return crops;
  });
});

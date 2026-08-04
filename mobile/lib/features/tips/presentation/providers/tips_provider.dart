import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/features/tips/data/datasources/tips_remote_datasource.dart';
import 'package:mobile/features/tips/data/models/quick_tip_model.dart';
import 'package:mobile/features/tips/data/repositories/tips_repository_impl.dart';
import 'package:mobile/features/tips/domain/repositories/tips_repository.dart';
import 'package:mobile/core/network/translation_service.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

final tipsRemoteDataSourceProvider = Provider<TipsRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return TipsRemoteDataSourceImpl(dio);
});

final tipsRepositoryProvider = Provider<TipsRepository>((ref) {
  final remoteDataSource = ref.watch(tipsRemoteDataSourceProvider);
  return TipsRepositoryImpl(remoteDataSource);
});

final quickTipsProvider = FutureProvider.autoDispose<List<QuickTipModel>>((ref) async {
  final repository = ref.watch(tipsRepositoryProvider);
  final translationService = ref.watch(translationServiceProvider);
  final targetLang = ref.watch(currentUserProvider)?.language ?? 'en';
  final cancelToken = CancelToken();
  
  ref.onDispose(() {
    cancelToken.cancel();
  });

  // Keep alive for session caching
  ref.keepAlive();
  
  final tips = await repository.getTips(cancelToken: cancelToken);
  
  if (targetLang == 'en') return tips;

  final translatedTips = <QuickTipModel>[];
  for (final tip in tips) {
    final title = await translationService.translateText(tip.title, targetLang);
    final description = await translationService.translateText(tip.description, targetLang);
    // You might also want to translate content if tip has it, but let's stick to title/desc for simplicity
    translatedTips.add(tip.copyWith(title: title, description: description));
  }
  
  return translatedTips;
});

final tipsSearchQueryProvider = StateProvider<String>((ref) => '');
final tipsCategoryFilterProvider = StateProvider<String?>((ref) => null);
final tipsCropFilterProvider = StateProvider<String?>((ref) => null);

final filteredTipsProvider = Provider.autoDispose<AsyncValue<List<QuickTipModel>>>((ref) {
  final tipsAsync = ref.watch(quickTipsProvider);
  final query = ref.watch(tipsSearchQueryProvider).toLowerCase();
  final categoryFilter = ref.watch(tipsCategoryFilterProvider);
  final cropFilter = ref.watch(tipsCropFilterProvider);

  return tipsAsync.whenData((tips) {
    return tips.where((tip) {
      final matchesQuery = query.isEmpty ||
          tip.title.toLowerCase().contains(query) ||
          tip.description.toLowerCase().contains(query) ||
          tip.category.toLowerCase().contains(query) ||
          (tip.crop?.toLowerCase().contains(query) ?? false) ||
          tip.tags.any((tag) => tag.toLowerCase().contains(query));
          
      final matchesCategory = categoryFilter == null || tip.category == categoryFilter;
      final matchesCrop = cropFilter == null || tip.crop == cropFilter;
      
      return matchesQuery && matchesCategory && matchesCrop;
    }).toList();
  });
});

final tipsAvailableCategoriesProvider = Provider.autoDispose<AsyncValue<List<String>>>((ref) {
  final tipsAsync = ref.watch(quickTipsProvider);
  
  return tipsAsync.whenData((tips) {
    final categories = tips.map((t) => t.category).toSet().toList();
    categories.sort();
    return categories;
  });
});

final tipsAvailableCropsProvider = Provider.autoDispose<AsyncValue<List<String>>>((ref) {
  final tipsAsync = ref.watch(quickTipsProvider);
  
  return tipsAsync.whenData((tips) {
    final crops = tips.where((t) => t.crop != null).map((t) => t.crop!).toSet().toList();
    crops.sort();
    return crops;
  });
});

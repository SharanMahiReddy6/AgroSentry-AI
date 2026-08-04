import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

class TranslationService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  
  final Map<String, String> _cache = {};

  Future<String> translateText(String text, String targetLang) async {
    if (text.isEmpty) return text;
    if (targetLang == 'en' || targetLang.isEmpty) return text;

    final cacheKey = '${targetLang}_$text';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await _dio.get(
        'https://translate.googleapis.com/translate_a/single',
        queryParameters: {
          'client': 'gtx',
          'sl': 'en',
          'tl': targetLang,
          'dt': 't',
          'q': text,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        if (data.isNotEmpty && data[0] is List) {
          final StringBuffer sb = StringBuffer();
          for (var segment in data[0]) {
            if (segment is List && segment.isNotEmpty) {
              sb.write(segment[0].toString());
            }
          }
          final translated = sb.toString();
          _cache[cacheKey] = translated;
          return translated;
        }
      }
      return text; // Fall back to English
    } catch (e) {
      return text; // Fall back to English
    }
  }
}

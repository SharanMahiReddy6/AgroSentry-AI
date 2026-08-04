import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/router/app_router.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AgroSentryApp()));
}

class AgroSentryApp extends ConsumerWidget {
  const AgroSentryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final user = ref.watch(authProvider).user;
    
    ThemeMode themeMode = ThemeMode.light;
    if (user?.theme == 'dark') {
      themeMode = ThemeMode.dark;
    } else if (user?.theme == 'system') {
      themeMode = ThemeMode.system;
    }

    return MaterialApp.router(
      title: (AppLocalizations.of(context)?.agrosentry ?? 'AgroSentry'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: user?.language != null ? Locale(user!.language!) : const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardEmptyState extends StatelessWidget {
  final VoidCallback? onScanPressed;

  const DashboardEmptyState({super.key, this.onScanPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: (AppLocalizations.of(context)?.emptyDashboardStateNoDataAvailable ?? 'Empty Dashboard State. No data available.'),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.yard_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 24),
              Text(
                (AppLocalizations.of(context)?.welcomeToAgrosentry ?? 'Welcome to AgroSentry!'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                (AppLocalizations.of(context)?.yourDashboardWillUpdateOnceYouCompleteYo ?? 'Your dashboard will update once you complete your first crop scan.'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onScanPressed ?? () => context.go('/scan'),
                icon: const Icon(Icons.camera_alt),
                label: Text((AppLocalizations.of(context)?.startFirstScan ?? 'Start First Scan')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 2,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

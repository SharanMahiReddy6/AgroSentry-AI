import 'package:mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/features/tips/data/models/quick_tip_model.dart';

class TipDetailScreen extends StatelessWidget {
  final QuickTipModel tip;

  const TipDetailScreen({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppScaffold(
      title: (AppLocalizations.of(context)?.tipDetails ?? 'Tip Details'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(
                          tip.category,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: theme.colorScheme.surface,
                        side: BorderSide.none,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text(tip.readTime, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    label: 'Tip Title: ${tip.title}',
                    child: Text(
                      tip.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('By ${tip.author}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    (AppLocalizations.of(context)?.overview ?? 'Overview'),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tip.description,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                  
                  if (tip.detailedContent != null && tip.detailedContent!.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      (AppLocalizations.of(context)?.detailedInformation ?? 'Detailed Information'),
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        tip.detailedContent!,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

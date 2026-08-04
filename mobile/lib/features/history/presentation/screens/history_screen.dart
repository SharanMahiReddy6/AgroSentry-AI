import 'package:mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/core/env/env.dart';
import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/features/history/presentation/providers/history_provider.dart';
import 'package:mobile/features/scan/presentation/providers/scan_provider.dart';
import 'package:mobile/features/scan/data/models/scan_history_model.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _buildUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final base = Env.apiBaseUrl.replaceAll(RegExp(r'/api/?$'), '');
    return '$base$path';
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ScanHistoryModel scan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text((AppLocalizations.of(context)?.deleteScan ?? 'Delete Scan')),
        content: Text('Are you sure you want to delete the scan for ${scan.crop}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text((AppLocalizations.of(context)?.cancel ?? 'Cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(historyProvider.notifier).deleteScan(scan.id);
              if (success) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text((AppLocalizations.of(context)?.scanDeletedSuccessfully ?? 'Scan deleted successfully.'))),
                  );
                }
              } else {
                if (context.mounted) {
                  final error = ref.read(historyProvider).deleteError ?? 'Deletion failed';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text((AppLocalizations.of(context)?.delete ?? 'Delete'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);

    ref.listen<HistoryState>(historyProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return AppScaffold(
      title: (AppLocalizations.of(context)?.scanHistory ?? 'Scan History'),
      body: state.isLoading && state.history.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => notifier.fetchHistory(isRefresh: true),
              child: state.history.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: state.history.length,
                      itemBuilder: (context, index) {
                        final scan = state.history[index];
                        return _buildHistoryCard(context, ref, scan);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const SizedBox(height: 64),
        const Icon(Icons.history, size: 80, color: Colors.grey),
        const SizedBox(height: 24),
        Text(
          (AppLocalizations.of(context)?.noScansYet ?? 'No Scans Yet'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          (AppLocalizations.of(context)?.yourPreviousPlantDiseaseScansWillAppearH ?? 'Your previous plant disease scans will appear here.'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => context.go('/scan'),
          child: Text((AppLocalizations.of(context)?.startScanning ?? 'Start Scanning')),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(BuildContext context, WidgetRef ref, ScanHistoryModel scan) {
    final isHealthy = scan.prediction.toLowerCase().contains('healthy');
    final statusColor = isHealthy ? Colors.green : Colors.redAccent;
    final formattedDate = _formatDate(scan.timestamp);

    return Semantics(
      label: 'Scan history item for ${scan.crop}: ${scan.prediction}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            ref.read(scanProvider.notifier).fetchScanDetails(scan.id);
            context.push('/scan/result');
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              SizedBox(
                width: 100,
                height: 120,
                child: CachedNetworkImage(
                  imageUrl: _buildUrl(scan.imageUrl),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              // Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isHealthy ? 'Healthy' : 'Diseased',
                              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scan.prediction,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Crop: ${scan.crop}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Confidence: ${scan.confidence}%',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              // Delete Action
              Semantics(
                label: (AppLocalizations.of(context)?.deleteScan ?? 'Delete scan'),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(context, ref, scan),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return isoString;
    }
  }
}

import 'package:mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/features/notifications/data/models/notification_model.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notif;

  const NotificationDetailScreen({super.key, required this.notif});

  IconData _getIcon() {
    if (notif.type == 'scan') return Icons.document_scanner;
    if (notif.type == 'alert') return Icons.warning_amber_rounded;
    return Icons.notifications;
  }

  Color _getIconColor(ThemeData theme) {
    if (notif.priority == 'high') return Colors.red;
    if (notif.type == 'scan') return Colors.blue;
    return theme.colorScheme.primary;
  }

  String _formatDateTime() {
    try {
      final date = DateTime.parse(notif.createdAt);
      return DateFormat('MMMM d, yyyy - h:mm a').format(date);
    } catch (_) {
      return notif.createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = _getIconColor(theme);

    return AppScaffold(
      title: (AppLocalizations.of(context)?.notificationDetails ?? 'Notification Details'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: iconColor.withValues(alpha: 0.1),
                    child: Icon(_getIcon(), color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.type.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: iconColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(),
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (notif.priority == 'high')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (AppLocalizations.of(context)?.urgent ?? 'URGENT'),
                        style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Semantics(
                label: 'Title: ${notif.title}',
                child: Text(
                  notif.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Semantics(
                label: 'Message: ${notif.message}',
                child: Text(
                  notif.message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              
              if (notif.scanId != null) ...[
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // context.push('/scan/result', extra: notif.scanId);
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: Text((AppLocalizations.of(context)?.viewRelatedScan ?? 'View Related Scan')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

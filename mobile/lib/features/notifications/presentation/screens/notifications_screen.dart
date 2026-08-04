import 'package:mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/core/widgets/empty_view.dart';
import 'package:mobile/features/notifications/data/models/notification_model.dart';
import 'package:mobile/features/notifications/presentation/providers/notification_provider.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String _categorizeDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final compareDate = DateTime(date.year, date.month, date.day);

      if (compareDate == today) return 'Today';
      if (compareDate == yesterday) return 'Yesterday';
      return 'Older';
    } catch (_) {
      return 'Older';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      title: (AppLocalizations.of(context)?.notifications ?? 'Notifications'),
      actions: [
        IconButton(
          icon: const Icon(Icons.done_all),
          tooltip: 'Mark all as read',
          onPressed: () {
            ref.read(notificationsProvider.notifier).markAllAsRead();
          },
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsProvider.notifier).loadNotifications(),
        child: notificationsState.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Semantics(
                      label: (AppLocalizations.of(context)?.noNotifications ?? 'No notifications'),
                      child: const EmptyView(
                        message: 'You have no new notifications.',
                      ),
                    ),
                  ),
                ],
              );
            }

            final Map<String, List<NotificationModel>> grouped = {
              'Today': [],
              'Yesterday': [],
              'Older': [],
            };

            for (var notif in notifications) {
              grouped[_categorizeDate(notif.createdAt)]!.add(notif);
            }

            return CustomScrollView(
              slivers: [
                if (grouped['Today']!.isNotEmpty) ...[
                  _buildHeader(theme, 'Today'),
                  _buildList(grouped['Today']!),
                ],
                if (grouped['Yesterday']!.isNotEmpty) ...[
                  _buildHeader(theme, 'Yesterday'),
                  _buildList(grouped['Yesterday']!),
                ],
                if (grouped['Older']!.isNotEmpty) ...[
                  _buildHeader(theme, 'Older'),
                  _buildList(grouped['Older']!),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text((AppLocalizations.of(context)?.failedToLoadNotifications ?? 'Failed to load notifications'), style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.read(notificationsProvider.notifier).loadNotifications(),
                  child: Text((AppLocalizations.of(context)?.retry ?? 'Retry')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<NotificationModel> list) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final notif = list[index];
          return _NotificationTile(notif: notif);
        },
        childCount: list.length,
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notif;

  const _NotificationTile({required this.notif});

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

  String _formatTime() {
    try {
      final date = DateTime.parse(notif.createdAt);
      return DateFormat.jm().format(date); // e.g. "5:08 PM"
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isUnread = !notif.isRead;

    return Semantics(
      label: '${isUnread ? "Unread " : ""}Notification: ${notif.title}',
      child: Material(
        color: isUnread ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(notificationsProvider.notifier).markAsRead(notif.id);
            context.push('/notifications/detail', extra: notif);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: _getIconColor(theme).withValues(alpha: 0.1),
                  child: Icon(_getIcon(), color: _getIconColor(theme)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isUnread ? theme.colorScheme.primary : Colors.grey,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

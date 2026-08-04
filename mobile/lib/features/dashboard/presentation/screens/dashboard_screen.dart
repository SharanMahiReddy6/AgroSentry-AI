import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobile/features/dashboard/presentation/widgets/dashboard_stats_card.dart';
import 'package:mobile/features/dashboard/presentation/widgets/quick_action_card.dart';
import 'package:mobile/features/dashboard/presentation/widgets/recent_scan_card.dart';
import 'package:mobile/features/dashboard/presentation/widgets/quick_tip_card.dart';
import 'package:mobile/features/dashboard/presentation/widgets/dashboard_skeleton.dart';
import 'package:mobile/features/dashboard/presentation/widgets/dashboard_empty_state.dart';
import 'package:mobile/l10n/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final dashboardState = ref.watch(dashboardProvider);
    final currentDate = _getFormattedDate();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboardData(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: _buildBody(context, ref, dashboardState, user, currentDate),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, dashboardState, user, String currentDate) {
    if (dashboardState.isLoading && dashboardState.recentScans.isEmpty) {
      return const DashboardSkeleton(key: ValueKey('skeleton'));
    }

    if (dashboardState.error != null && dashboardState.recentScans.isEmpty) {
      return _buildErrorState(context, ref, dashboardState.error!);
    }

    return SingleChildScrollView(
      key: const ValueKey('loaded'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Section
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                backgroundImage: (user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty)
                    ? NetworkImage(user.profilePhoto!)
                    : null,
                child: (user?.profilePhoto == null || user!.profilePhoto!.isEmpty)
                    ? Icon(Icons.person, size: 32, color: Theme.of(context).primaryColor)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.fullName ?? 'Guest'} 👋',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentDate,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Statistics Cards or Empty State
          if (dashboardState.recentScans.isEmpty) ...[
            DashboardEmptyState(onScanPressed: () => context.go('/scan')),
          ] else ...[
            Text(
              (AppLocalizations.of(context)?.overview ?? 'Overview'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                const crossAxisCount = 2;
                const spacing = 16.0;
                final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;
                // Minimum height for the card to fit all content (icon, value, title, padding)
                const itemHeight = 120.0;
                final aspectRatio = itemWidth / itemHeight;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: aspectRatio,
                  children: [
                    DashboardStatsCard(
                      title: (AppLocalizations.of(context)?.totalScans ?? 'Total Scans'),
                      value: dashboardState.totalScans.toString(),
                      icon: Icons.document_scanner_rounded,
                      color: Colors.blue,
                    ),
                    DashboardStatsCard(
                      title: (AppLocalizations.of(context)?.healthyPlants ?? 'Healthy Plants'),
                      value: dashboardState.healthyPlants.toString(),
                      icon: Icons.eco_rounded,
                      color: Colors.green,
                    ),
                    DashboardStatsCard(
                      title: (AppLocalizations.of(context)?.diseasedPlants ?? 'Diseased Plants'),
                      value: dashboardState.diseasedPlants.toString(),
                      icon: Icons.coronavirus_rounded,
                      color: Colors.red,
                    ),
                    DashboardStatsCard(
                      title: (AppLocalizations.of(context)?.avgAccuracy ?? 'Avg. Accuracy'),
                      value: '${dashboardState.accuracy.toStringAsFixed(1)}%',
                      icon: Icons.insights_rounded,
                      color: Colors.orange,
                    ),
                  ],
                );
              }
            ),
          ],
          
          const SizedBox(height: 36),

          // Quick Actions
          Text(
            AppLocalizations.of(context)?.quickActions ?? 'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: QuickActionCard(title: (AppLocalizations.of(context)?.scan ?? 'Scan'), icon: Icons.camera_alt_rounded, onTap: () => context.go('/scan'))),
              Expanded(child: QuickActionCard(title: (AppLocalizations.of(context)?.history ?? 'History'), icon: Icons.history_rounded, onTap: () => context.go('/history'))),
              Expanded(child: QuickActionCard(title: (AppLocalizations.of(context)?.library ?? 'Library'), icon: Icons.library_books_rounded, onTap: () => context.go('/library'))),
              Expanded(child: QuickActionCard(title: (AppLocalizations.of(context)?.tips ?? 'Tips'), icon: Icons.lightbulb_rounded, onTap: () => context.push('/tips'))),
            ],
          ),
          const SizedBox(height: 36),

          // Quick Tips
          if (dashboardState.quickTips.isNotEmpty) ...[
            Text(
              AppLocalizations.of(context)?.quickTips ?? 'Quick Tips',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: dashboardState.quickTips.length > 5 ? 5 : dashboardState.quickTips.length,
                itemBuilder: (context, index) {
                  final tip = dashboardState.quickTips[index];
                  return QuickTipCard(
                    title: tip.title,
                    description: tip.content,
                    onTap: () => context.push('/tips'),
                  );
                },
              ),
            ),
            const SizedBox(height: 36),
          ],

          // Recent Scans
          if (dashboardState.recentScans.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)?.recentScans ?? 'Recent Scans',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go('/history'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: Text((AppLocalizations.of(context)?.viewAll ?? 'View All')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...dashboardState.recentScans.take(3).map((scan) {
              final isHealthy = scan.prediction.toLowerCase() == 'healthy';
              final formattedDate = _formatScanDate(scan.createdAt);
              
              return RecentScanCard(
                cropName: scan.cropType,
                result: scan.prediction,
                date: formattedDate,
                isHealthy: isHealthy,
              );
            }),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return CustomScrollView(
      key: const ValueKey('error'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 80, color: Colors.orangeAccent),
                const SizedBox(height: 24),
                Text(
                  (AppLocalizations.of(context)?.oopsConnectionLost ?? 'Oops! Connection Lost'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, height: 1.5)),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => ref.read(dashboardProvider.notifier).loadDashboardData(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text((AppLocalizations.of(context)?.tryAgain ?? 'Try Again')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _formatScanDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/core/env/env.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/notifications/presentation/providers/notification_provider.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  String _buildPhotoUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    String cleanPath = path;
    if (cleanPath.startsWith('file://')) {
      cleanPath = cleanPath.replaceFirst('file://', '');
    }
    if (!cleanPath.startsWith('/')) cleanPath = '/$cleanPath';
    final base = Env.apiBaseUrl.replaceAll(RegExp(r'/api/?$'), '');
    return '$base$cleanPath';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text((AppLocalizations.of(context)?.agrosentry ?? 'AgroSentry')),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => context.push('/notifications'),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                navigationShell.goBranch(4, initialLocation: true);
              },
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                backgroundImage: user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty
                    ? CachedNetworkImageProvider(_buildPhotoUrl(user.profilePhoto)) 
                    : null,
                child: user?.profilePhoto == null ? const Icon(Icons.person, color: Colors.white) : null,
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user?.fullName ?? 'Guest'),
                accountEmail: Text(user?.email ?? 'guest@example.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white24,
                  backgroundImage: user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty
                      ? CachedNetworkImageProvider(_buildPhotoUrl(user.profilePhoto)) 
                      : null,
                  child: user?.profilePhoto == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(AppLocalizations.of(context)?.settings ?? 'Settings'),
                onTap: () {},
              ),
              if (user?.isAdmin == true)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: Text(AppLocalizations.of(context)?.adminPortal ?? 'Admin Portal'),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    context.push('/admin');
                  },
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_outlined, color: Colors.red),
                title: Text(AppLocalizations.of(context)?.logout ?? 'Logout', style: const TextStyle(color: Colors.red)),
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                },
              ),
            ],
          ),
        ),
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: AppLocalizations.of(context)?.dashboard ?? 'Dashboard',
          ),
          NavigationDestination(
            icon: const Icon(Icons.camera_alt_outlined),
            selectedIcon: const Icon(Icons.camera_alt),
            label: AppLocalizations.of(context)?.scan ?? 'Scan',
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: AppLocalizations.of(context)?.history ?? 'History',
          ),
          NavigationDestination(
            icon: const Icon(Icons.library_books_outlined),
            selectedIcon: const Icon(Icons.library_books),
            label: AppLocalizations.of(context)?.library ?? 'Library',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: AppLocalizations.of(context)?.profile ?? 'Profile',
          ),
        ],
      ),
    );
  }
}

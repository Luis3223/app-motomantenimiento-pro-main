import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../screens/add_registry_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/history_screen.dart';
import '../screens/login_screen.dart';
import '../screens/manage_service_types_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../screens/service_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/notification_banner.dart';

const whatsappNumber = '3225062876';
const storeUrl = 'https://tiendavirtualcasaracing.vercel.app/';

Future<void> openWhatsApp() async {
  final uri = Uri.parse('https://wa.me/57$whatsappNumber');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> openStore() async {
  final uri = Uri.parse(storeUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

GoRouter createAppRouter(AppController controller) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: controller,
    redirect: (context, state) {
      final loggedIn = controller.currentUser != null;
      final loc = state.matchedLocation;
      final onAuth = loc == '/login' || loc == '/register';
      if (!controller.ready) return null;
      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn && onAuth) return '/garage';
      if (loc.startsWith('/history/admin') &&
          controller.currentUser?.isAdmin != true) {
        return '/history';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
      GoRoute(
        path: '/manage-services',
        builder: (context, state) => ManageServiceTypesScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/garage',
                builder: (context, state) => DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) => DetailScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => HistoryScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => AddRegistryScreen(),
                  ),
                  GoRoute(
                    path: 'service',
                    builder: (context, state) => ServiceDetailScreen(),
                  ),
                  GoRoute(
                    path: 'admin',
                    builder: (context, state) => AdminScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, _) {
        return Scaffold(
          body: Stack(
            children: [
              navigationShell,
              NotificationBanner(
                alert: controller.showNotificationAlert,
                onDismiss: controller.dismissNotificationAlert,
              ),
            ],
          ),
          bottomNavigationBar: Container(
            color: context.navBarColor,
            padding: EdgeInsets.only(top: 10, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.two_wheeler,
                  label: 'Mi Garage',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => navigationShell.goBranch(0),
                ),
                _NavItem(
                  icon: Icons.history,
                  label: 'Historial',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => navigationShell.goBranch(1),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  label: 'Mi Perfil',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => navigationShell.goBranch(2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.red : context.textSecondary,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.red : context.textSecondary,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 6),
          Container(
            height: 2,
            width: 60,
            color: isSelected ? Colors.red : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

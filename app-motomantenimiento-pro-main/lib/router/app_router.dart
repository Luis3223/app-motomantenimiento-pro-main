import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/app_controller.dart';
import '../screens/add_registry_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/history_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../widgets/notification_banner.dart';

const whatsappNumber = '3225062876';
const storeUrl = 'https://tiendavirtualcasaracing.lovable.app/';

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
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
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
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) => const DetailScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddRegistryScreen(),
                  ),
                  GoRoute(
                    path: 'admin',
                    builder: (context, state) => const AdminScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
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
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: navigationShell.goBranch,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.two_wheeler_outlined),
                selectedIcon: Icon(Icons.two_wheeler),
                label: 'Mi Garage',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'Historial',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Mi Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}

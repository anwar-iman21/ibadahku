import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/admin/admin_screens.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/user/history_screen.dart';
import '../screens/user/home_screen.dart';
import '../screens/user/information_screen.dart';
import '../screens/user/qurban_screen.dart';
import '../screens/user/settings_screen.dart';
import '../screens/user/zakat_fitrah_screen.dart';
import '../screens/user/zakat_maal_screen.dart';
import '../screens/user/zakat_menu_screen.dart';
import '../widgets/adaptive_shell.dart';
import '../widgets/sheep_icon.dart';

Page<void> _fade(GoRouterState s, Widget child) => CustomTransitionPage<void>(
  key: s.pageKey,
  child: child,
  transitionDuration: const Duration(milliseconds: 280),
  transitionsBuilder:
      (context, anim, secondary, child) =>
          FadeTransition(opacity: anim, child: child),
);

Page<void> _slide(GoRouterState s, Widget child) => CustomTransitionPage<void>(
  key: s.pageKey,
  child: child,
  transitionDuration: const Duration(milliseconds: 300),
  transitionsBuilder: (context, anim, secondary, child) {
    final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  },
);

const _userItems = [
  NavItem('Beranda', Icons.home_outlined, Icons.home_rounded),
  NavItem(
    'Zakat',
    Icons.volunteer_activism_outlined,
    Icons.volunteer_activism_rounded,
  ),
  NavItem(
    'Qurban',
    Icons.pets_outlined,
    Icons.pets_rounded,
    customIcon: SheepIcon(),
    customSelectedIcon: SheepIcon(filled: true),
  ),
  NavItem('Riwayat', Icons.history_outlined, Icons.history_rounded),
  NavItem('Akun', Icons.person_outline_rounded, Icons.person_rounded),
];

const _adminItems = [
  NavItem('Dashboard', Icons.dashboard_outlined, Icons.dashboard_rounded),
  NavItem('Harga', Icons.sell_outlined, Icons.sell_rounded),
  NavItem('Konten', Icons.article_outlined, Icons.article_rounded),
  NavItem('Pengguna', Icons.group_outlined, Icons.group_rounded),
  NavItem('Akun', Icons.person_outline_rounded, Icons.person_rounded),
];

GoRouter buildRouter(AuthProvider auth) {
  const sharedInformationPaths = {
    '/panduan',
    '/privasi',
    '/syarat',
    '/bantuan',
  };
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (auth.status == AuthStatus.unknown) {
        return loc == '/splash' ? null : '/splash';
      }
      final inAuth = loc == '/login' || loc == '/register';
      if (auth.status == AuthStatus.signedOut) {
        return inAuth ? null : '/login';
      }
      final home = auth.isAdmin ? '/admin' : '/home';
      if (loc == '/splash' || inAuth) return home;
      if (auth.isAdmin &&
          !loc.startsWith('/admin') &&
          !sharedInformationPaths.contains(loc)) {
        return home;
      }
      if (!auth.isAdmin && loc.startsWith('/admin')) return home;
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (c, s) => _fade(s, const SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (c, s) => _fade(s, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (c, s) => _slide(s, const RegisterScreen()),
      ),
      GoRoute(
        path: '/panduan',
        pageBuilder:
            (c, s) => _slide(
              s,
              const InformationScreen(section: InformationSection.guide),
            ),
      ),
      GoRoute(
        path: '/privasi',
        pageBuilder:
            (c, s) => _slide(
              s,
              const InformationScreen(section: InformationSection.privacy),
            ),
      ),
      GoRoute(
        path: '/syarat',
        pageBuilder:
            (c, s) => _slide(
              s,
              const InformationScreen(section: InformationSection.terms),
            ),
      ),
      GoRoute(
        path: '/bantuan',
        pageBuilder:
            (c, s) => _slide(
              s,
              const InformationScreen(section: InformationSection.help),
            ),
      ),

      // ---------------- USER ----------------
      StatefulShellRoute.indexedStack(
        builder:
            (context, state, shell) => AdaptiveShell(
              shell: shell,
              items: _userItems,
              roleLabel: 'Pengguna',
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (c, s) => _fade(s, const HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/zakat',
                pageBuilder: (c, s) => _fade(s, const ZakatMenuScreen()),
                routes: [
                  GoRoute(
                    path: 'fitrah',
                    pageBuilder: (c, s) => _slide(s, const ZakatFitrahScreen()),
                  ),
                  GoRoute(
                    path: 'maal',
                    pageBuilder: (c, s) => _slide(s, const ZakatMaalScreen()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/qurban',
                pageBuilder: (c, s) => _fade(s, const QurbanScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/riwayat',
                pageBuilder: (c, s) => _fade(s, const HistoryScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/akun',
                pageBuilder: (c, s) => _fade(s, const SettingsScreen()),
              ),
            ],
          ),
        ],
      ),

      // ---------------- ADMIN ----------------
      StatefulShellRoute.indexedStack(
        builder:
            (context, state, shell) => AdaptiveShell(
              shell: shell,
              items: _adminItems,
              roleLabel: 'Administrator',
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                pageBuilder: (c, s) => _fade(s, const AdminDashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/harga',
                pageBuilder: (c, s) => _fade(s, const AdminPricesScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/konten',
                pageBuilder: (c, s) => _fade(s, const AdminContentScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/pengguna',
                pageBuilder: (c, s) => _fade(s, const AdminUsersScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/akun',
                pageBuilder: (c, s) => _fade(s, const AdminAccountScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

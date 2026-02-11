import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/screens/add_expense_screen.dart';
import 'package:kakeibo/screens/all_expenses_screen.dart';
import 'package:kakeibo/screens/fixed_expenses_screen.dart';
import 'package:kakeibo/screens/home_screen.dart';
import 'package:kakeibo/screens/reflection_screen.dart';
import 'package:kakeibo/screens/settings_screen.dart';
import 'package:kakeibo/screens/setup_screen.dart';
import 'package:kakeibo/theme/app_theme.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return _BottomNavShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/expenses',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) => const AllExpensesScreen(),
        ),
        GoRoute(
          path: '/settings',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    // Modal routes (full-screen, above bottom nav)
    GoRoute(
      path: '/setup',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: '/add-expense',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: '/edit-expense/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => AddExpenseScreen(
        editExpenseId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: '/fixed-expenses',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FixedExpensesScreen(),
    ),
    GoRoute(
      path: '/reflection',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReflectionScreen(),
    ),
  ],
);

class KakeiboApp extends StatelessWidget {
  const KakeiboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kakeibo',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _BottomNavShell extends StatelessWidget {
  const _BottomNavShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            activeIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/expenses')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/expenses');
      case 2:
        context.go('/settings');
    }
  }
}

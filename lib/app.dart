import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/screens/add_expense_screen.dart';
import 'package:kakeibo/screens/all_expenses_screen.dart';
import 'package:kakeibo/screens/about_screen.dart';
import 'package:kakeibo/screens/add_fixed_expense_screen.dart';
import 'package:kakeibo/screens/add_income_screen.dart';
import 'package:kakeibo/screens/fixed_expenses_screen.dart';
import 'package:kakeibo/screens/import_screen.dart';
import 'package:kakeibo/screens/income_screen.dart';
import 'package:kakeibo/screens/home_screen.dart';
import 'package:kakeibo/screens/reflection_screen.dart';
import 'package:kakeibo/screens/settings_screen.dart';
import 'package:kakeibo/screens/setup_screen.dart';
import 'package:kakeibo/services/swipe_nav.dart';
import 'package:kakeibo/theme/app_theme.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => SwipeNav.slidePage(
        state: state,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/expenses',
      pageBuilder: (context, state) => SwipeNav.slidePage(
        state: state,
        child: const AllExpensesScreen(),
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: '/fixed-expenses',
      pageBuilder: (context, state) => SwipeNav.slidePage(
        state: state,
        child: const FixedExpensesScreen(),
      ),
    ),
    GoRoute(
      path: '/reflection',
      builder: (context, state) => const ReflectionScreen(),
    ),
    GoRoute(
      path: '/add-fixed-expense',
      builder: (context, state) => const AddFixedExpenseScreen(),
    ),
    GoRoute(
      path: '/edit-fixed-expense/:id',
      builder: (context, state) => AddFixedExpenseScreen(
        editFixedExpenseId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: '/income',
      builder: (context, state) => const IncomeScreen(),
    ),
    GoRoute(
      path: '/add-income',
      builder: (context, state) => const AddIncomeScreen(),
    ),
    GoRoute(
      path: '/edit-income/:id',
      builder: (context, state) => AddIncomeScreen(
        editIncomeId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: '/import-fixed-costs',
      builder: (context, state) =>
          const ImportScreen(importType: ImportType.fixedCosts),
    ),
    GoRoute(
      path: '/import-income',
      builder: (context, state) =>
          const ImportScreen(importType: ImportType.income),
    ),
    GoRoute(
      path: '/add-expense',
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: '/edit-expense/:id',
      builder: (context, state) => AddExpenseScreen(
        editExpenseId: state.pathParameters['id'],
      ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/import_type.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/database_provider.dart';
import 'package:kakeibo/screens/toy_about_screen.dart';
import 'package:kakeibo/screens/toy_add_expense_screen.dart';
import 'package:kakeibo/screens/toy_add_fixed_expense_screen.dart';
import 'package:kakeibo/screens/toy_add_income_screen.dart';
import 'package:kakeibo/screens/toy_all_expenses_screen.dart';
import 'package:kakeibo/screens/toy_category_breakdown_screen.dart';
import 'package:kakeibo/screens/toy_fixed_expenses_screen.dart';
import 'package:kakeibo/screens/toy_home_screen.dart';
import 'package:kakeibo/screens/toy_import_screen.dart';
import 'package:kakeibo/screens/toy_income_screen.dart';
import 'package:kakeibo/screens/toy_payday_settings_screen.dart';
import 'package:kakeibo/screens/toy_reflection_screen.dart';
import 'package:kakeibo/screens/toy_rename_categories_screen.dart';
import 'package:kakeibo/screens/toy_search_screen.dart';
import 'package:kakeibo/screens/toy_settings_screen.dart';
import 'package:kakeibo/screens/toy_setup_screen.dart';
import 'package:kakeibo/services/auto_backup_manager.dart';
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
        child: const ToyHomeScreen(),
      ),
    ),
    GoRoute(
      path: '/expenses',
      pageBuilder: (context, state) {
        final pillarName = state.uri.queryParameters['pillar'];
        final pillar = pillarName == null
            ? null
            : Pillar.values.where((p) => p.name == pillarName).firstOrNull;
        return SwipeNav.slidePage(
          state: state,
          child: ToyAllExpensesScreen(
            initialPillar: pillar,
            initialCategory: state.uri.queryParameters['category'],
          ),
        );
      },
    ),
    GoRoute(
      path: '/category-breakdown',
      builder: (context, state) => const ToyCategoryBreakdownScreen(),
    ),
    GoRoute(
      path: '/fixed-expenses',
      pageBuilder: (context, state) => SwipeNav.slidePage(
        state: state,
        child: const ToyFixedExpensesScreen(),
      ),
    ),
    GoRoute(
      path: '/reflection',
      builder: (context, state) => const ToyReflectionScreen(),
    ),
    GoRoute(
      path: '/setup',
      builder: (context, state) => const ToySetupScreen(),
    ),
    GoRoute(
      path: '/income',
      builder: (context, state) => const ToyIncomeScreen(),
    ),
    GoRoute(
      path: '/add-expense',
      builder: (context, state) => const ToyAddExpenseScreen(),
    ),
    GoRoute(
      path: '/edit-expense/:id',
      builder: (context, state) =>
          ToyAddExpenseScreen(editExpenseId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/add-fixed-expense',
      builder: (context, state) => const ToyAddFixedExpenseScreen(),
    ),
    GoRoute(
      path: '/edit-fixed-expense/:id',
      builder: (context, state) => ToyAddFixedExpenseScreen(
        editFixedExpenseId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: '/add-income',
      builder: (context, state) => const ToyAddIncomeScreen(),
    ),
    GoRoute(
      path: '/edit-income/:id',
      builder: (context, state) => ToyAddIncomeScreen(
        editIncomeId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const ToySettingsScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const ToyAboutScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const ToySearchScreen(),
    ),
    GoRoute(
      path: '/import-fixed-costs',
      builder: (context, state) =>
          const ToyImportScreen(importType: ImportType.fixedCosts),
    ),
    GoRoute(
      path: '/import-income',
      builder: (context, state) =>
          const ToyImportScreen(importType: ImportType.income),
    ),
    GoRoute(
      path: '/rename-categories',
      builder: (context, state) => const ToyRenameCategoriesScreen(),
    ),
    GoRoute(
      path: '/payday-settings',
      builder: (context, state) => const ToyPaydaySettingsScreen(),
    ),
  ],
);

class KakeiboApp extends ConsumerStatefulWidget {
  const KakeiboApp({super.key});

  @override
  ConsumerState<KakeiboApp> createState() => _KakeiboAppState();
}

class _KakeiboAppState extends ConsumerState<KakeiboApp> {
  AutoBackupManager? _autoBackupManager;

  @override
  void initState() {
    super.initState();
    // Delay to ensure providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoBackupManager = AutoBackupManager(ref.read(databaseProvider));
      _autoBackupManager!.init();
    });
  }

  @override
  void dispose() {
    _autoBackupManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kakeibo',
      theme: AppTheme.current,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/database_provider.dart';
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
import 'package:kakeibo/screens/rename_categories_screen.dart';
import 'package:kakeibo/screens/search_screen.dart';
import 'package:kakeibo/screens/payday_settings_screen.dart';
import 'package:kakeibo/screens/settings_screen.dart';
import 'package:kakeibo/screens/setup_screen.dart';
import 'package:kakeibo/screens/toy_about_screen.dart';
import 'package:kakeibo/screens/toy_add_expense_screen.dart';
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
        child: const HomeScreen(),
      ),
    ),
    // Preview-only routes for the gachapon redesign. Reachable from
    // each other via the toy tab bar so review can move between the
    // screens that exist so far without falling through to the real,
    // unconverted app. Remove once the redesign either replaces the
    // real routes or is abandoned.
    GoRoute(
      path: '/toy-dashboard',
      builder: (context, state) => const ToyHomeScreen(),
    ),
    GoRoute(
      path: '/toy-expenses',
      builder: (context, state) {
        final pillarName = state.uri.queryParameters['pillar'];
        final pillar = pillarName == null
            ? null
            : Pillar.values.where((p) => p.name == pillarName).firstOrNull;
        return ToyAllExpensesScreen(
          initialPillar: pillar,
          initialCategory: state.uri.queryParameters['category'],
        );
      },
    ),
    GoRoute(
      path: '/toy-category-breakdown',
      builder: (context, state) => const ToyCategoryBreakdownScreen(),
    ),
    GoRoute(
      path: '/toy-fixed-expenses',
      builder: (context, state) => const ToyFixedExpensesScreen(),
    ),
    GoRoute(
      path: '/toy-reflection',
      builder: (context, state) => const ToyReflectionScreen(),
    ),
    GoRoute(
      path: '/toy-setup',
      builder: (context, state) => const ToySetupScreen(),
    ),
    GoRoute(
      path: '/toy-income',
      builder: (context, state) => const ToyIncomeScreen(),
    ),
    GoRoute(
      path: '/toy-add-expense',
      builder: (context, state) => const ToyAddExpenseScreen(),
    ),
    GoRoute(
      path: '/toy-edit-expense/:id',
      builder: (context, state) =>
          ToyAddExpenseScreen(editExpenseId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/toy-settings',
      builder: (context, state) => const ToySettingsScreen(),
    ),
    GoRoute(
      path: '/toy-about',
      builder: (context, state) => const ToyAboutScreen(),
    ),
    GoRoute(
      path: '/toy-search',
      builder: (context, state) => const ToySearchScreen(),
    ),
    GoRoute(
      path: '/toy-import-fixed-costs',
      builder: (context, state) => const ToyImportScreen(importType: ImportType.fixedCosts),
    ),
    GoRoute(
      path: '/toy-import-income',
      builder: (context, state) => const ToyImportScreen(importType: ImportType.income),
    ),
    GoRoute(
      path: '/toy-rename-categories',
      builder: (context, state) => const ToyRenameCategoriesScreen(),
    ),
    GoRoute(
      path: '/toy-payday-settings',
      builder: (context, state) => const ToyPaydaySettingsScreen(),
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
      path: '/rename-categories',
      builder: (context, state) => const RenameCategoriesScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/payday-settings',
      builder: (context, state) => const PaydaySettingsScreen(),
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

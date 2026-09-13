import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/models/user_settings.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/screens/toy_add_fixed_expense_screen.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// Smoke test for Save fixed cost, added alongside the Save income fix per
/// Codex's review -- the app owner's live report mentioned the same
/// dark-yellow/lighter-shadow button appearance on the Fixed Cost form as
/// on Income, and while _canSave here only depends on the amount field
/// (which already had a working listener, so this screen was never
/// actually exposed to the missing-listener bug), it's still worth a real
/// tap-and-persist check rather than assuming the code-reading conclusion
/// holds without ever exercising it.
void main() {
  Future<void> pumpAddFixedExpenseScreen(
    WidgetTester tester, {
    required _RecordingKakeiboMonthsNotifier monthsNotifier,
  }) async {
    final router = GoRouter(
      initialLocation: '/fixed-expenses',
      routes: [
        GoRoute(
          path: '/fixed-expenses',
          builder: (context, state) => const Text('Fixed costs screen reached'),
        ),
        GoRoute(
          path: '/add-fixed-expense',
          builder: (context, state) => const ToyAddFixedExpenseScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(() => _FakeSettingsNotifier()),
          currentMonthIdProvider.overrideWith((ref) => '2026-09'),
          kakeiboMonthsProvider.overrideWith(() => monthsNotifier),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    router.push('/add-fixed-expense');
    await tester.pumpAndSettle();
  }

  testWidgets(
      'tapping Save fixed cost after entering just an amount persists the '
      'entry (with the default Other category) and returns to Fixed Costs',
      (tester) async {
    final monthsNotifier = _RecordingKakeiboMonthsNotifier();
    await pumpAddFixedExpenseScreen(tester, monthsNotifier: monthsNotifier);

    // Only the amount is required here (_canSave has no name/category
    // requirement, unlike Income) -- confirms the button is reachable
    // and does something with the minimum valid input, not just when
    // every field happens to be filled in.
    await tester.enterText(find.byType(TextField).first, '52.00');
    await tester.pump();

    await tester.tap(find.byType(ToyPrimaryButton));
    await tester.pumpAndSettle();

    expect(monthsNotifier.addFixedExpenseCalls, hasLength(1));
    final call = monthsNotifier.addFixedExpenseCalls.single;
    expect(call.monthId, '2026-09');
    expect(call.amount, 52.00);
    expect(call.category, 'Other', reason: 'unset category defaults to Other');

    expect(find.text('Fixed costs screen reached'), findsOneWidget,
        reason: 'Save fixed cost must actually navigate back once the '
            'save has completed');
  });

  testWidgets('Save fixed cost stays disabled with no amount entered',
      (tester) async {
    final monthsNotifier = _RecordingKakeiboMonthsNotifier();
    await pumpAddFixedExpenseScreen(tester, monthsNotifier: monthsNotifier);

    final button = tester.widget<ToyPrimaryButton>(find.byType(ToyPrimaryButton));
    expect(button.onTap, isNull);
  });
}

class _RecordingKakeiboMonthsNotifier extends KakeiboMonthsNotifier {
  final addFixedExpenseCalls = <({
    String monthId,
    String name,
    double amount,
    String category,
    int? dueDay,
  })>[];

  @override
  Future<List<KakeiboMonth>> build() async => [];

  @override
  Future<void> addFixedExpense({
    required String monthId,
    required String name,
    required double amount,
    required String category,
    int? dueDay,
  }) async {
    addFixedExpenseCalls.add((
      monthId: monthId,
      name: name,
      amount: amount,
      category: category,
      dueDay: dueDay,
    ));
  }
}

class _FakeSettingsNotifier extends SettingsNotifier {
  @override
  Future<UserSettings> build() async => const UserSettings();
}

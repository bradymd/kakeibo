import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/models/user_settings.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/screens/toy_add_income_screen.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// Regression test for a real bug reported live: "I put in the money and
/// fill in the description [name field]. It won't action" -- the Save
/// income button stayed visually disabled/faded (its enabled-state
/// BoxDecoration renders lighter, which reads as "a second, lighter
/// button behind it") and completely unresponsive to taps, even after
/// both the amount and name fields were filled in correctly.
///
/// Root cause: _canSave depends on BOTH _amountController's and
/// _nameController's text, but initState() only added a listener to
/// _amountController -- ToyAddIncomeScreen never rebuilt (never
/// re-evaluated _canSave, never passed a fresh onTap to ToyPrimaryButton)
/// when only the name field changed. If the user's last edit before
/// tapping Save was to the name field (exactly "type the amount, then
/// type the name" -- the order in the bug report), the button's onTap
/// stayed stuck at whatever _canSave evaluated to on the last
/// amount-triggered rebuild: null, if the name was still empty then.
///
/// Fixed by adding an equivalent listener on _nameController.
void main() {
  Future<void> pumpAddIncomeScreen(
    WidgetTester tester, {
    required _RecordingKakeiboMonthsNotifier monthsNotifier,
    bool pushFromIncome = false,
  }) async {
    final router = GoRouter(
      initialLocation: '/income',
      routes: [
        // A distinguishable prior screen so context.pop() (what the
        // Save button actually calls, not context.go) has a real route
        // to return to -- without this, Add Income would be the only
        // entry on the stack and pop() would be a no-op.
        GoRoute(
          path: '/income',
          builder: (context, state) => const Text('Income screen reached'),
        ),
        GoRoute(
          path: '/add-income',
          builder: (context, state) => const ToyAddIncomeScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(
            () => _FakeSettingsNotifier(),
          ),
          currentMonthIdProvider.overrideWith((ref) => '2026-09'),
          kakeiboMonthsProvider.overrideWith(() => monthsNotifier),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    if (pushFromIncome) {
      router.push('/add-income');
      await tester.pumpAndSettle();
    }
  }

  testWidgets(
      'typing the amount, then the name LAST, enables Save income -- '
      'exactly the order in the reported bug', (tester) async {
    await pumpAddIncomeScreen(tester, monthsNotifier: _RecordingKakeiboMonthsNotifier(), pushFromIncome: true);

    // Amount first (this field's listener already worked before the fix).
    await tester.enterText(find.byType(TextField).first, '250.00');
    await tester.pump();

    // Name/description LAST -- this is the field whose listener was
    // missing. Before the fix, the button's onTap would still be null
    // here because nothing told the widget to re-evaluate _canSave after
    // this specific field changed.
    await tester.enterText(find.byType(TextField).at(1), 'Freelance');
    await tester.pump();

    final button = tester.widget<ToyPrimaryButton>(find.byType(ToyPrimaryButton));
    expect(button.onTap, isNotNull,
        reason: 'Save income must be enabled once both amount and name are '
            'filled in, regardless of which field was edited last');
  });

  testWidgets('typing the name first, then the amount, also enables Save income',
      (tester) async {
    // The reverse order already worked before the fix (the amount
    // field's listener covered this case) -- kept as a sanity check that
    // the fix didn't only handle one direction.
    await pumpAddIncomeScreen(tester, monthsNotifier: _RecordingKakeiboMonthsNotifier(), pushFromIncome: true);

    await tester.enterText(find.byType(TextField).at(1), 'Freelance');
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '250.00');
    await tester.pump();

    final button = tester.widget<ToyPrimaryButton>(find.byType(ToyPrimaryButton));
    expect(button.onTap, isNotNull);
  });

  testWidgets('Save income stays disabled while the name is still empty',
      (tester) async {
    await pumpAddIncomeScreen(tester, monthsNotifier: _RecordingKakeiboMonthsNotifier(), pushFromIncome: true);

    await tester.enterText(find.byType(TextField).first, '250.00');
    await tester.pump();

    final button = tester.widget<ToyPrimaryButton>(find.byType(ToyPrimaryButton));
    expect(button.onTap, isNull,
        reason: 'an empty name must still block Save, not just render a '
            'faded button that happens to have a live onTap underneath');
  });

  testWidgets(
      'tapping Save income (amount then name last) actually persists the '
      'entry and returns to Income -- not just onTap != null',
      (tester) async {
    // Per Codex's review: the three tests above only ever inspected
    // ToyPrimaryButton.onTap, which proves the enable/disable regression
    // is fixed but never proves a tap actually reaches addIncomeSource,
    // that it's called with the right arguments, or that the screen exits
    // afterwards -- the full user-level contract the bug report actually
    // cared about ("it won't action").
    final monthsNotifier = _RecordingKakeiboMonthsNotifier();
    await pumpAddIncomeScreen(tester, monthsNotifier: monthsNotifier, pushFromIncome: true);

    await tester.enterText(find.byType(TextField).first, '250.00');
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(1), 'Freelance');
    await tester.pump();

    await tester.tap(find.byType(ToyPrimaryButton));
    await tester.pumpAndSettle();

    expect(monthsNotifier.addIncomeSourceCalls, hasLength(1));
    final call = monthsNotifier.addIncomeSourceCalls.single;
    expect(call.monthId, '2026-09');
    expect(call.name, 'Freelance');
    expect(call.amount, 250.00);

    // The screen only pops after the awaited save completes -- confirms
    // this isn't a fire-and-forget tap that merely looked like it worked.
    expect(find.text('Income screen reached'), findsOneWidget,
        reason: 'Save income must actually navigate back to Income once '
            'the save has completed, not just accept the tap');
  });
}

/// Records addIncomeSource calls instead of touching a real database --
/// this test is about the widget/provider contract (does a tap reach the
/// notifier with the right arguments, does the screen wait for it), not
/// about exercising AppDatabase itself, which is already covered
/// elsewhere. build() returns an empty month list since
/// ToyAddIncomeScreen's add-new path doesn't read currentMonthProvider at
/// all (only the edit path does).
class _RecordingKakeiboMonthsNotifier extends KakeiboMonthsNotifier {
  final addIncomeSourceCalls = <({String monthId, String name, double amount})>[];

  @override
  Future<List<KakeiboMonth>> build() async => [];

  @override
  Future<void> addIncomeSource({
    required String monthId,
    required String name,
    required double amount,
  }) async {
    addIncomeSourceCalls.add((monthId: monthId, name: name, amount: amount));
  }
}

class _FakeSettingsNotifier extends SettingsNotifier {
  @override
  Future<UserSettings> build() async => const UserSettings();
}

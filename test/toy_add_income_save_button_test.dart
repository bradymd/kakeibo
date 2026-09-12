import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
  Future<void> pumpAddIncomeScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(
            () => _FakeSettingsNotifier(),
          ),
          currentMonthIdProvider.overrideWith((ref) => '2026-09'),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/add-income',
            routes: [
              GoRoute(
                path: '/add-income',
                builder: (context, state) => const ToyAddIncomeScreen(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
      'typing the amount, then the name LAST, enables Save income -- '
      'exactly the order in the reported bug', (tester) async {
    await pumpAddIncomeScreen(tester);

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
    await pumpAddIncomeScreen(tester);

    await tester.enterText(find.byType(TextField).at(1), 'Freelance');
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '250.00');
    await tester.pump();

    final button = tester.widget<ToyPrimaryButton>(find.byType(ToyPrimaryButton));
    expect(button.onTap, isNotNull);
  });

  testWidgets('Save income stays disabled while the name is still empty',
      (tester) async {
    await pumpAddIncomeScreen(tester);

    await tester.enterText(find.byType(TextField).first, '250.00');
    await tester.pump();

    final button = tester.widget<ToyPrimaryButton>(find.byType(ToyPrimaryButton));
    expect(button.onTap, isNull,
        reason: 'an empty name must still block Save, not just render a '
            'faded button that happens to have a live onTap underneath');
  });
}

class _FakeSettingsNotifier extends SettingsNotifier {
  @override
  Future<UserSettings> build() async => const UserSettings();
}

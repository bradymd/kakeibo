import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/import_type.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/models/user_settings.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/screens/toy_import_screen.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

class _FakeSettingsNotifier extends SettingsNotifier {
  @override
  Future<UserSettings> build() async => const UserSettings();
}

/// Regression tests for the "Copy from another month" duplicate-safety
/// gap Codex's review identified: an 11px muted caption had already
/// failed once as a warning (an owner selected and copied a flagged
/// duplicate without registering it), so the fix replaces it with a
/// conspicuous badge, a duplicate count on the Copy button, and a
/// confirmation dialog that blocks the copy until explicitly accepted.
///
/// A fake notifier records every addFixedExpense call and lets the test
/// simulate the "destination changed while the screen was open" case by
/// mutating its own in-memory state before the test taps Copy.
class _RecordingNotifier extends KakeiboMonthsNotifier {
  _RecordingNotifier(this._initial);

  final List<KakeiboMonth> _initial;
  final List<String> addedNames = [];

  @override
  Future<List<KakeiboMonth>> build() async => _initial;

  @override
  Future<void> addFixedExpense({
    required String monthId,
    required String name,
    required double amount,
    required String category,
    int? dueDay,
  }) async {
    addedNames.add(name);
    final months = state.value ?? _initial;
    state = AsyncData([
      for (final m in months)
        if (m.id == monthId)
          m.copyWith(fixedExpenses: [
            ...m.fixedExpenses,
            FixedExpense(
              id: 'new-${addedNames.length}',
              name: name,
              amount: amount,
              category: category,
              dueDay: dueDay,
            ),
          ])
        else
          m,
    ]);
  }
}

void main() {
  final sourceMonth = KakeiboMonth(
    id: '2026-08',
    year: 2026,
    month: 8,
    fixedExpenses: const [
      FixedExpense(id: 'src-affinity', name: 'Affinity', amount: 83.0, category: 'Water'),
      FixedExpense(id: 'src-rent', name: 'Rent', amount: 900.0, category: 'Housing'),
    ],
  );

  Future<_RecordingNotifier> pumpImportScreen(
    WidgetTester tester, {
    required KakeiboMonth destinationMonth,
  }) async {
    final notifier = _RecordingNotifier([sourceMonth, destinationMonth]);
    final router = GoRouter(
      // A real route behind the import screen -- the screen calls
      // context.pop() after a successful copy, which needs somewhere to
      // pop back to (matches the real app's shape: this screen is always
      // pushed, never the initial route).
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/import-fixed-costs',
          builder: (context, state) =>
              const ToyImportScreen(importType: ImportType.fixedCosts),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          kakeiboMonthsProvider.overrideWith(() => notifier),
          currentMonthIdProvider.overrideWith((ref) => destinationMonth.id),
          settingsProvider.overrideWith(_FakeSettingsNotifier.new),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    router.push('/import-fixed-costs');
    await tester.pumpAndSettle();
    return notifier;
  }

  group('ToyImportScreen duplicate warning', () {
    testWidgets('a flagged duplicate shows "Already added" and starts unchecked',
        (tester) async {
      final destination = KakeiboMonth(
        id: '2026-09',
        year: 2026,
        month: 9,
        fixedExpenses: const [
          FixedExpense(id: 'dst-affinity', name: 'Affinity', amount: 83.0, category: 'Water'),
        ],
      );
      await pumpImportScreen(tester, destinationMonth: destination);

      expect(find.text('Already added'), findsOneWidget);
      // Rent is not a duplicate -- its row has no badge.
      expect(find.text('Will add duplicate'), findsNothing);
    });

    testWidgets('tapping a flagged duplicate switches the badge to "Will add duplicate"',
        (tester) async {
      final destination = KakeiboMonth(
        id: '2026-09',
        year: 2026,
        month: 9,
        fixedExpenses: const [
          FixedExpense(id: 'dst-affinity', name: 'Affinity', amount: 83.0, category: 'Water'),
        ],
      );
      await pumpImportScreen(tester, destinationMonth: destination);

      await tester.tap(find.text('Water · Affinity'));
      await tester.pump();

      expect(find.text('Will add duplicate'), findsOneWidget);
      expect(find.text('Already added'), findsNothing);
    });

    testWidgets('Copy button shows the duplicate count once a duplicate is selected',
        (tester) async {
      final destination = KakeiboMonth(
        id: '2026-09',
        year: 2026,
        month: 9,
        fixedExpenses: const [
          FixedExpense(id: 'dst-affinity', name: 'Affinity', amount: 83.0, category: 'Water'),
        ],
      );
      await pumpImportScreen(tester, destinationMonth: destination);

      // Only Rent is selected by default (Affinity defaults off).
      expect(find.textContaining('includes'), findsNothing);

      await tester.tap(find.text('Water · Affinity'));
      await tester.pump();

      expect(find.textContaining('includes 1 duplicate'), findsOneWidget);
    });

    testWidgets('pressing Copy on a selected duplicate shows a confirmation dialog; '
        'Cancel makes no insert', (tester) async {
      final destination = KakeiboMonth(
        id: '2026-09',
        year: 2026,
        month: 9,
        fixedExpenses: const [
          FixedExpense(id: 'dst-affinity', name: 'Affinity', amount: 83.0, category: 'Water'),
        ],
      );
      final notifier = await pumpImportScreen(tester, destinationMonth: destination);

      await tester.tap(find.text('Water · Affinity'));
      await tester.pump();

      await tester.tap(find.byType(ToyPrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Copy duplicates?'), findsOneWidget);
      expect(find.textContaining('Affinity'), findsWidgets);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(notifier.addedNames, isEmpty);
    });

    testWidgets('confirming the dialog copies exactly once', (tester) async {
      final destination = KakeiboMonth(
        id: '2026-09',
        year: 2026,
        month: 9,
        fixedExpenses: const [
          FixedExpense(id: 'dst-affinity', name: 'Affinity', amount: 83.0, category: 'Water'),
        ],
      );
      final notifier = await pumpImportScreen(tester, destinationMonth: destination);

      await tester.tap(find.text('Water · Affinity'));
      await tester.pump();

      await tester.tap(find.byType(ToyPrimaryButton));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Copy anyway'));
      await tester.pumpAndSettle();

      // Copy iterates selectedMonth.fixedExpenses in its own order
      // (Affinity, then Rent, matching sourceMonth's definition above).
      expect(notifier.addedNames, ['Affinity', 'Rent']);
    });

    testWidgets('no duplicates selected: Copy proceeds without any dialog', (tester) async {
      final destination = KakeiboMonth(
        id: '2026-09',
        year: 2026,
        month: 9,
        fixedExpenses: const [
          FixedExpense(id: 'dst-affinity', name: 'Affinity', amount: 83.0, category: 'Water'),
        ],
      );
      final notifier = await pumpImportScreen(tester, destinationMonth: destination);

      // Affinity stays unchecked (its default); only Rent is selected.
      await tester.tap(find.byType(ToyPrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Copy duplicates?'), findsNothing);
      expect(notifier.addedNames, ['Rent']);
    });
  });
}

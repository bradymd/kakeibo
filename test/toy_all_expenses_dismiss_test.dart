import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/screens/toy_all_expenses_screen.dart';

/// Regression test for the swipe-to-delete "yellow text on dark red" bug:
/// Dismissible requires the dismissed widget gone from the tree by the
/// time onDismissed returns, but deleteExpense awaits a db write before
/// invalidating the
/// provider supplying the list -- so a slow delete left the row's key
/// still present, tripping Flutter's own "still part of the tree"
/// assertion and painting its debug ErrorWidget for however long the
/// delete took.
///
/// Uses a fake notifier with a controllable delay rather than a real
/// database, so the test can assert on the exact window between dismiss
/// and the delete actually completing.
class _DelayedDeleteNotifier extends KakeiboMonthsNotifier {
  _DelayedDeleteNotifier(this._initial, this._deleteGate);

  final List<KakeiboMonth> _initial;
  final Completer<void> _deleteGate;

  @override
  Future<List<KakeiboMonth>> build() async => _initial;

  @override
  Future<void> deleteExpense(String id) async {
    await _deleteGate.future;
    final months = state.value ?? _initial;
    state = AsyncData([
      for (final m in months)
        m.copyWith(expenses: m.expenses.where((e) => e.id != id).toList()),
    ]);
  }
}

void main() {
  testWidgets(
      'a slow delete does not trip a "still part of the tree" assertion',
      (tester) async {
    final deleteGate = Completer<void>();
    final month = KakeiboMonth(
      id: '2026-09',
      year: 2026,
      month: 9,
      expenses: [
        const KakeiboExpense(
          id: 'e1',
          date: '2026-09-01',
          description: 'Tesco',
          amount: 12.5,
          pillar: Pillar.needs,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          kakeiboMonthsProvider.overrideWith(
            () => _DelayedDeleteNotifier([month], deleteGate),
          ),
          currentMonthIdProvider.overrideWith((ref) => month.id),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/expenses',
            routes: [
              GoRoute(
                path: '/expenses',
                builder: (context, state) => const ToyAllExpensesScreen(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Tesco'), findsOneWidget);

    // Swipe the row away (endToStart matches the screen's
    // DismissDirection.endToStart). Dismissible needs the drag to clear
    // its dismiss threshold, so use a decisive fling rather than a slow
    // drag, then let its own drag-settle animation finish before
    // confirmDismiss fires and the dialog opens.
    await tester.fling(find.text('Tesco'), const Offset(-500, 0), 1000);
    await tester.pumpAndSettle();

    // confirmDismiss shows a dialog -- accept it.
    expect(find.text('Delete expense?'), findsOneWidget);
    final deleteButton = find.widgetWithText(TextButton, 'Delete');
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
    await tester.pump();

    // Pump past Dismissible's movement (~200ms) + resize (~300ms)
    // animations while the delete is still gated -- this is the exact
    // window the original bug occurred in.
    await tester.pump(const Duration(milliseconds: 600));

    // The row must already be gone from the tree (Dismissible's own
    // contract), and no exception should have been thrown/caught by the
    // framework in the process.
    expect(find.text('Tesco'), findsNothing);
    expect(tester.takeException(), isNull);

    // Let the delete actually complete and settle.
    deleteGate.complete();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  });
}

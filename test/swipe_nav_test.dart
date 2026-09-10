import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/services/swipe_nav.dart';
import 'package:kakeibo/widgets/toy/toy_tab_bar.dart';

/// Regression test for the swipe-navigation inconsistency across the four
/// bottom-tab screens (Month/Spend/Fixed/Income): each screen used to hand
/// -wire its own onHorizontalDragEnd with its own hardcoded pair of
/// neighbour routes, and the four had drifted out of sync with each other
/// and with the tab bar's own order -- e.g. swiping one direction on Month
/// skipped straight over Spend to Fixed, and Fixed/Income had no swipe
/// handling at all. SwipeNav.handleTabSwipe replaced all four bespoke
/// copies with one function that steps through ToyTabDestination.values,
/// so this test drives that function directly against a minimal router
/// covering just the four tab paths -- no need for the real screens, which
/// require live database/provider state to render.
void main() {
  Future<String> currentPathAfterSwipe(
    WidgetTester tester, {
    required ToyTabDestination from,
    required double velocity,
  }) async {
    late BuildContext capturedContext;
    String currentPath = from.path;

    final router = GoRouter(
      initialLocation: from.path,
      routes: [
        for (final dest in ToyTabDestination.values)
          GoRoute(
            path: dest.path,
            builder: (context, state) {
              currentPath = dest.path;
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    SwipeNav.handleTabSwipe(capturedContext, from, velocity);
    await tester.pumpAndSettle();

    return currentPath;
  }

  group('SwipeNav.handleTabSwipe', () {
    testWidgets('positive velocity advances one step forward through tab order',
        (tester) async {
      expect(
        await currentPathAfterSwipe(tester, from: ToyTabDestination.month, velocity: 500),
        ToyTabDestination.spend.path,
      );
    });

    testWidgets('from Spend, positive velocity advances to Fixed (not skipping/reordering)',
        (tester) async {
      expect(
        await currentPathAfterSwipe(tester, from: ToyTabDestination.spend, velocity: 500),
        ToyTabDestination.fixed.path,
      );
    });

    testWidgets('from Fixed, positive velocity advances to Income', (tester) async {
      expect(
        await currentPathAfterSwipe(tester, from: ToyTabDestination.fixed, velocity: 500),
        ToyTabDestination.income.path,
      );
    });

    testWidgets('negative velocity goes back one step', (tester) async {
      expect(
        await currentPathAfterSwipe(tester, from: ToyTabDestination.income, velocity: -500),
        ToyTabDestination.fixed.path,
      );
    });

    testWidgets('positive velocity on the last tab (Income) is a no-op -- no wraparound',
        (tester) async {
      expect(
        await currentPathAfterSwipe(tester, from: ToyTabDestination.income, velocity: 500),
        ToyTabDestination.income.path,
      );
    });

    testWidgets('negative velocity on the first tab (Month) is a no-op -- no wraparound',
        (tester) async {
      expect(
        await currentPathAfterSwipe(tester, from: ToyTabDestination.month, velocity: -500),
        ToyTabDestination.month.path,
      );
    });

    testWidgets('velocity below the threshold does nothing', (tester) async {
      expect(
        await currentPathAfterSwipe(tester, from: ToyTabDestination.spend, velocity: 100),
        ToyTabDestination.spend.path,
      );
      expect(
        await currentPathAfterSwipe(tester, from: ToyTabDestination.spend, velocity: -100),
        ToyTabDestination.spend.path,
      );
    });
  });
}

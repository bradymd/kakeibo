import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// Regression test for the bottom-safe-area bug found on a real Android
/// phone: the tab bar used to be a plain child inside the Scaffold body's
/// Column with a hardcoded 24px bottom padding, so on a device whose own
/// system navigation bar reports a real bottom inset taller than that, the
/// OS drew its nav bar directly over the tab pills, making them untappable.
///
/// Fixed by moving ToyTabBar into Scaffold.bottomNavigationBar (so Scaffold
/// can measure it and position the FAB off Scaffold's own contentBottom via
/// the standard endFloat location) and having ToyTabBar's own SafeArea use
/// `minimum: EdgeInsets.only(bottom: 24)` -- max(24, device inset), not
/// 24-plus-inset.
///
/// This file's first version had assertions weak enough to pass against a
/// second, independent bug the bottomNavigationBar move introduced: Codex
/// found that _TabPill's Container (non-null `alignment`) expanded to fill
/// the *entire* screen height, because Scaffold gives bottomNavigationBar a
/// finite bounded height (unlike the old unbounded body-Column placement),
/// and Row passes that bound down to its Expanded children. The bar visually
/// covered the whole screen and silently ate every touch meant for the body
/// underneath -- including the real Dismissible swipe-to-delete gesture on
/// the Spend screen (test/toy_all_expenses_dismiss_test.dart). "the label's
/// dy is less than the viewport height" and "the bar's bottom touches the
/// viewport bottom" are both still true of a full-screen bar, so neither
/// caught it. Fixed by giving each pill an explicit 44px height (SizedBox
/// around _TabPill). These tests now assert a *bounded* bar/pill height and
/// that the FAB is actually on-screen, not just "above" an off-screen bar.
void main() {
  Future<void> pumpScaffold(WidgetTester tester, {required double bottomInset}) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomInset)),
        child: MaterialApp(
          home: ToyScaffold(
            title: 'Test',
            tab: ToyTabDestination.month,
            floatingActionButton: ToyFab(onTap: () {}),
            body: const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ToyScaffold bottom safe-area handling', () {
    testWidgets('with no device inset, the tab bar is a bounded ~80px bar and each '
        'pill/label is a normal-sized text line, not a full-screen overlay',
        (tester) async {
      await pumpScaffold(tester, bottomInset: 0);

      // Bounded height, not "somewhere on screen" -- 12 top padding + 44
      // pill + 24 bottom minimum = 80, loosely bounded rather than pinned
      // to an exact pixel count (shadows/borders could nudge it slightly).
      // This is the exact assertion the original (weaker) version of this
      // test lacked: a full-screen ~600px-tall bar also satisfies "label
      // dy < viewport height" and "bar bottom touches viewport bottom",
      // which is why it slipped through undetected until Codex measured
      // the actual rendered rectangles and found each pill was ~564px tall.
      final tabBarHeight = tester.getSize(find.byType(ToyTabBar)).height;
      expect(tabBarHeight, closeTo(80, 4));

      for (final dest in ToyTabDestination.values) {
        final finder = find.text(dest.label);
        expect(finder, findsOneWidget, reason: '${dest.label} tab should be rendered');
        final size = tester.getSize(finder);
        // A full-screen bar would also put labels "on screen" -- assert
        // the label's own rendered height is small (a single text line),
        // not spread across ~564px the way the full-screen-bug pill was.
        expect(size.height, lessThan(30),
            reason: '${dest.label} label must be a normal text line, not '
                'stretched across a full-screen pill');
      }
    });

    testWidgets(
        'with a large device inset (48, standing in for a tall system nav bar), '
        'the bar grows by the inset but stays bounded, and every pill is '
        'individually on-screen and tappable', (tester) async {
      await pumpScaffold(tester, bottomInset: 48);

      // Bar grows by the extra inset (24 minimum -> 48 actual), not to
      // fill the viewport: 12 + 44 + 48 = 104.
      final tabBarHeight = tester.getSize(find.byType(ToyTabBar)).height;
      expect(tabBarHeight, closeTo(104, 4));

      final viewportHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final tabBarTop = tester.getTopLeft(find.byType(ToyTabBar)).dy;
      expect(tabBarTop, greaterThan(0),
          reason: 'the bar must not cover the whole screen from y=0');
      expect(tabBarTop, closeTo(viewportHeight - 104, 4));

      for (final dest in ToyTabDestination.values) {
        final finder = find.text(dest.label);
        expect(finder, findsOneWidget, reason: '${dest.label} tab should be rendered');
        expect(tester.getSize(finder).height, lessThan(30),
            reason: '${dest.label} label must be a normal text line');
      }
    });

    testWidgets('the FAB sits above the tab bar, fully on-screen, not overlapping it',
        (tester) async {
      await pumpScaffold(tester, bottomInset: 48);

      final fabRect = tester.getRect(find.byType(ToyFab));
      final tabBarTop = tester.getTopLeft(find.byType(ToyTabBar)).dy;

      // A full-screen bar previously pushed the FAB off the top of the
      // viewport entirely (observed: fabBottom around -16) while still
      // satisfying "fabBottom <= tabBarTop" -- assert the FAB is actually
      // on-screen, not just numerically above the bar's (possibly bogus)
      // top edge.
      expect(fabRect.top, greaterThanOrEqualTo(0),
          reason: 'the FAB must be on-screen, not pushed off the top');
      expect(fabRect.bottom, lessThanOrEqualTo(tabBarTop),
          reason: 'the FAB must not overlap the measured tab bar');
    });

    testWidgets('a small inset (typical iPhone home indicator, ~34) still shows a bar '
        'no shorter than the original 24px minimum, and no taller than bounded',
        (tester) async {
      await pumpScaffold(tester, bottomInset: 34);

      final tabBarHeight = tester.getSize(find.byType(ToyTabBar)).height;
      // 12 top + 44 pill + max(24, 34) bottom = 90, loosely bounded on
      // both sides so this can't silently regress back to full-screen.
      expect(tabBarHeight, greaterThanOrEqualTo(24 + 12));
      expect(tabBarHeight, closeTo(90, 4));
    });

    testWidgets('each tab pill has a bounded, sane height (guards against the '
        'alignment-expands-to-fill-bottomNavigationBar bug)', (tester) async {
      await pumpScaffold(tester, bottomInset: 0);

      // Directly measure a pill's own rendered box, not just its label's --
      // this is the exact widget whose Container expanded to ~564px tall
      // when the bug was present.
      final pillFinder = find.ancestor(
        of: find.text('Month'),
        matching: find.byType(SizedBox),
      );
      expect(tester.getSize(pillFinder.first).height, closeTo(44, 1));
    });
  });
}

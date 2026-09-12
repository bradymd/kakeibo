import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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

    testWidgets(
        'with a large device inset (48), tapping an inactive pill actually '
        'navigates -- proves the real hit target, not just its geometry',
        (tester) async {
      // Per Codex's review of 955f39e: the geometry assertions above prove
      // the bar/pills are bounded and on-screen, but the reported production
      // symptom was specifically "tabs are untappable" -- a real tap needs a
      // GoRouter ancestor (the pill's onTap calls context.go), which the
      // bare-MaterialApp harness above deliberately doesn't set up, so this
      // test builds one directly instead.
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(bottom: 48)),
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => ToyScaffold(
                    title: 'Month',
                    tab: ToyTabDestination.month,
                    floatingActionButton: ToyFab(onTap: () {}),
                    body: const SizedBox.shrink(),
                  ),
                ),
                GoRoute(
                  path: '/expenses',
                  builder: (context, state) => ToyScaffold(
                    title: 'Spent',
                    tab: ToyTabDestination.spend,
                    floatingActionButton: ToyFab(onTap: () {}),
                    body: const Text('Spend screen reached'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spent'));
      await tester.pumpAndSettle();

      expect(find.text('Spend screen reached'), findsOneWidget,
          reason: 'tapping the Spent pill must actually route to /expenses, '
              'proving the pill is a real, reachable tap target -- not just '
              'correctly sized/positioned geometry');
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

  /// Regression test for a second, related on-device report: pushed screens
  /// (tab: null -- Settings, About, Start of Month, etc.) have nothing in
  /// ToyScaffold's bottomNavigationBar slot, so before this fix their body
  /// content ran straight to the device's physical bottom edge with
  /// whatever fixed padding each screen author happened to hardcode
  /// (typically 24). On the app owner's phone, this meant the last line of
  /// Settings/About sat uncomfortably close to (not fully hidden by, but
  /// tight against) the transparent system nav bar.
  ///
  /// Fixed by wrapping body in SafeArea(left: false, top: false, right:
  /// false) when tab == null. Per Codex's review: SafeArea's device inset
  /// and a screen's own bottom padding are additive (SafeArea wraps the
  /// child in Padding(bottom: max(device inset, minimum)) and never
  /// inspects the child) -- this is the correct, desired behaviour here:
  /// system clearance *plus* the screen's own deliberate visual breathing
  /// room, not a replacement for it.
  group('ToyScaffold tabless (tab: null) bottom safe-area handling', () {
    testWidgets(
        'a fixed bottom-aligned child ends exactly at the safe boundary '
        '(viewport height minus the device inset)', (tester) async {
      const bottomInset = 48.0;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(bottom: bottomInset)),
          child: MaterialApp(
            home: ToyScaffold(
              title: 'Test',
              // tab: null (the default) -- a pushed screen.
              body: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [Text('Bottom-aligned content', key: Key('fixedBottomChild'))],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final viewportHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final childBottom = tester.getBottomLeft(find.byKey(const Key('fixedBottomChild'))).dy;
      expect(childBottom, closeTo(viewportHeight - bottomInset, 0.5),
          reason: 'a fixed bottom child must end at the device safe boundary, '
              'not run to the physical screen edge');
    });

    testWidgets(
        'a scrollable with its own bottom padding retains BOTH the device '
        'inset AND that padding (additive, not a replacement)', (tester) async {
      const bottomInset = 48.0;
      const listBottomPadding = 24.0;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(bottom: bottomInset)),
          child: MaterialApp(
            home: ToyScaffold(
              title: 'Test',
              body: ListView(
                padding: const EdgeInsets.only(bottom: listBottomPadding),
                children: const [
                  SizedBox(height: 2000, child: Text('filler')), // force scrollability
                  Text('Last line', key: Key('lastListItem')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Scroll fully to the bottom -- this is what "the last line is
      // visible/hidden" actually depends on, not just static layout.
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      final viewportHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final lastItemBottom = tester.getBottomLeft(find.byKey(const Key('lastListItem'))).dy;
      // Per Codex: last ListView child with bottom:24 ends at
      // viewportHeight - inset - padding, i.e. both apply, not just one.
      expect(lastItemBottom, closeTo(viewportHeight - bottomInset - listBottomPadding, 1),
          reason: 'the device inset and the ListView\'s own bottom padding '
              'must both apply -- the inset must not silently replace or '
              'absorb the screen\'s own deliberate spacing');
    });
  });
}

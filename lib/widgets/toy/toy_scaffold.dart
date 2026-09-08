import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_tab_bar.dart';

/// The toy-themed screen scaffold (README "Global chrome" + per-screen
/// headers). New widget, parallel to the existing `KakeiboScaffold` —
/// screens migrate to this one at a time per the redesign's rollout
/// order, rather than all at once.
///
/// Header: fill [headerColor] (default brand pink) with the diagonal
/// stripe overlay, padding `14 20 16`, white text. Optional back arrow,
/// optional trailing action (hamburger/search), optional subtitle, and
/// an optional headline figure line.
///
/// Screens reached from the tab bar pass [tab] to render the bar and
/// keep it visible; pushed screens (no tab) get a back arrow instead
/// and no tab bar, per the README.
class ToyScaffold extends StatelessWidget {
  const ToyScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.headlineFigure,
    required this.body,
    this.tab,
    this.disabledTabs = const {},
    this.tabPathOverrides = const {},
    this.showBackButton = false,
    this.onBack,
    this.trailing,
    this.headerColor = ToyColors.brand,
    this.backgroundColor = ToyColors.bg,
    this.floatingActionButton,
  });

  final String title;
  final String? subtitle;

  /// Optional headline figure shown as a fourth header line (README:
  /// "the screen's headline figure, 32–34/900"), e.g. a running total.
  final String? headlineFigure;

  final Widget body;

  /// The active tab bar destination. Null hides the tab bar (pushed
  /// screens use a back arrow instead — see README "Global chrome").
  final ToyTabDestination? tab;
  final Set<ToyTabDestination> disabledTabs;

  /// See `ToyTabBar.pathOverrides` — mid-rollout escape hatch, remove
  /// once every tab destination has a converted screen at its real
  /// route.
  final Map<ToyTabDestination, String> tabPathOverrides;

  final bool showBackButton;
  final VoidCallback? onBack;

  /// Trailing header action — hamburger menu, search icon, etc.
  final Widget? trailing;

  final Color headerColor;
  final Color backgroundColor;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _Header(
            title: title,
            subtitle: subtitle,
            headlineFigure: headlineFigure,
            showBackButton: showBackButton,
            onBack: onBack,
            trailing: trailing,
            fillColor: headerColor,
          ),
          Expanded(child: body),
          if (tab != null)
            ToyTabBar(
              current: tab!,
              disabled: disabledTabs,
              pathOverrides: tabPathOverrides,
            ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: tab != null
          ? const _AboveTabBarFabLocation()
          : FloatingActionButtonLocation.endFloat,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.headlineFigure,
    required this.showBackButton,
    required this.onBack,
    required this.trailing,
    required this.fillColor,
  });

  final String title;
  final String? subtitle;
  final String? headlineFigure;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fillColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: const HeaderStripePainter()),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (showBackButton)
                        GestureDetector(
                          onTap: onBack ??
                              () {
                                if (Navigator.canPop(context)) {
                                  context.pop();
                                } else {
                                  context.go('/');
                                }
                              },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '←',
                              style: ToyTextStyles.headerTitle(fontSize: 20),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          title,
                          style: ToyTextStyles.headerTitle(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ?trailing,
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: ToyTextStyles.headerSubtitle()),
                  ],
                  if (headlineFigure != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      headlineFigure!,
                      style: ToyTextStyles.headerTotal().copyWith(
                        shadows: const [
                          Shadow(
                            color: Color(0x24000000),
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Positions the FAB at `right: 18, bottom: 70` measured from the top
/// of the tab bar, per the README ("Global chrome"). Flutter's FAB
/// locations are relative to the Scaffold, not the bottom bar directly,
/// so this offsets from the standard end-float position by the tab
/// bar's approximate height (the 24px bottom padding plus the pill).
class _AboveTabBarFabLocation extends FloatingActionButtonLocation {
  const _AboveTabBarFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final fabX = scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        18;
    final fabY = scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        70 -
        scaffoldGeometry.minInsets.bottom;
    return Offset(fabX, fabY);
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_tab_bar.dart';

/// The toy-themed screen scaffold (README "Global chrome" + per-screen
/// headers), used by every screen in the app.
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
    this.headerBottom,
    required this.body,
    this.tab,
    this.disabledTabs = const {},
    this.showBackButton = false,
    this.onBack,
    this.trailing,
    this.headerColor = ToyColors.brand,
    this.subtitleColor,
    this.backgroundColor = ToyColors.bg,
    this.floatingActionButton,
  });

  final String title;
  final String? subtitle;

  /// Optional headline figure shown as a fourth header line (README:
  /// "the screen's headline figure, 32–34/900"), e.g. a running total.
  final String? headlineFigure;

  /// Optional content below the subtitle/headline figure, e.g. a month
  /// navigator. Mirrors `KakeiboScaffold.headerBottom`.
  final Widget? headerBottom;

  final Widget body;

  /// The active tab bar destination. Null hides the tab bar (pushed
  /// screens use a back arrow instead — see README "Global chrome").
  final ToyTabDestination? tab;
  final Set<ToyTabDestination> disabledTabs;

  final bool showBackButton;
  final VoidCallback? onBack;

  /// Trailing header action — hamburger menu, search icon, etc.
  final Widget? trailing;

  final Color headerColor;

  /// Subtitle text colour override — README §5a switches this to
  /// `#FFC9D8` on the over-budget header. Defaults to the usual gold.
  final Color? subtitleColor;

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
            subtitleColor: subtitleColor,
            headlineFigure: headlineFigure,
            headerBottom: headerBottom,
            showBackButton: showBackButton,
            onBack: onBack,
            trailing: trailing,
            fillColor: headerColor,
          ),
          Expanded(
            // Tab-bar screens (bottomNavigationBar above) already get a
            // safe-area-aware bottom inset from ToyTabBar itself. Pushed
            // screens (tab == null -- Settings, About, Setup, Reflection,
            // etc.) have nothing in their bottomNavigationBar slot at all,
            // so without this SafeArea their body content ran straight to
            // the device's physical bottom edge with whatever fixed
            // padding each screen happened to hardcode (typically 24) --
            // on a phone with a tall transparent system nav bar, the last
            // line of content sits uncomfortably close to (reported: not
            // fully hidden, but tight against) that bar.
            //
            // SafeArea reserves the reported device inset outside the
            // child. Each screen's existing bottom padding remains inside
            // the safe viewport, intentionally preserving its visual
            // breathing room above system UI -- confirmed against
            // Flutter's own SafeArea source (it wraps the child in
            // Padding(bottom: max(MediaQuery.padding.bottom, minimum))
            // and never inspects the child), so this is genuinely
            // additive with a screen's own bottom padding, not a
            // replacement for it. Per Codex's audit of all thirteen
            // unique tabless screens: their bodies are scrollable,
            // flexible, or centered, with no body-level MediaQuery inset
            // reads or nested SafeAreas that would make this unsafe.
            //
            // left/right explicitly false (rather than relying on
            // SafeArea's left/right defaulting true) to keep this a
            // narrowly-scoped bottom-only fix -- tabbed bodies don't get
            // a horizontal wrapper here, so this shouldn't introduce a
            // surprise horizontal narrowing in landscape either.
            child: tab == null
                ? SafeArea(left: false, top: false, right: false, child: body)
                : body,
          ),
        ],
      ),
      // The tab bar lives in Scaffold's own bottomNavigationBar slot, not
      // inside body's Column, specifically so Scaffold can measure it and
      // set contentBottom correctly (see ToyTabBar's own doc comment for
      // why -- this was a real bug on a physical Android phone, where the
      // OS's own nav bar was drawn on top of untappable tab pills because
      // nothing here ever accounted for the device's actual bottom safe-
      // area inset). Per Codex's review: this also means the FAB no longer
      // needs a bespoke FloatingActionButtonLocation guessing the tab
      // bar's height -- Flutter's standard `endFloat` already positions
      // relative to Scaffold's measured contentBottom, which now correctly
      // reflects the tab bar's real, safe-area-aware height.
      bottomNavigationBar: tab == null
          ? null
          : ToyTabBar(current: tab!, disabled: disabledTabs),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    required this.headlineFigure,
    required this.headerBottom,
    required this.showBackButton,
    required this.onBack,
    required this.trailing,
    required this.fillColor,
  });

  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final String? headlineFigure;
  final Widget? headerBottom;
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
                    Text(
                      subtitle!,
                      style: subtitleColor != null
                          ? ToyTextStyles.headerSubtitle(color: subtitleColor!)
                          : ToyTextStyles.headerSubtitle(),
                    ),
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
                  if (headerBottom != null)
                    Padding(padding: const EdgeInsets.only(top: 12), child: headerBottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

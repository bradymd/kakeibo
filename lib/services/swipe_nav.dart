import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/widgets/toy/toy_tab_bar.dart';

enum SlideDirection { left, right, none }

class SwipeNav {
  static SlideDirection _direction = SlideDirection.none;

  static SlideDirection consumeDirection() {
    final d = _direction;
    _direction = SlideDirection.none;
    return d;
  }

  static void go(BuildContext context, String path, SlideDirection direction) {
    _direction = direction;
    context.go(path);
  }

  /// Handles a horizontal drag on one of the four bottom-tab screens
  /// (Month / Spend / Fixed / Income) by moving one step through
  /// [ToyTabDestination.values] in tab-bar order, rather than each screen
  /// wiring its own bespoke pair of neighbours. Previously each screen
  /// hand-wired its own left/right targets and the four disagreed with
  /// each other — Month skipped over Spend when swiping one direction,
  /// Spend used the opposite velocity-to-direction convention from Month,
  /// and Fixed/Income had no swipe handling at all.
  ///
  /// Convention (matches the app owner's own description): dragging left
  /// -to-right (positive [velocity]) advances forward through the tab
  /// order (Month → Spend → Fixed → Income); right-to-left goes back.
  /// Does nothing past either end of the list (no wraparound).
  static void handleTabSwipe(
    BuildContext context,
    ToyTabDestination current,
    double velocity,
  ) {
    const threshold = 300;
    if (velocity <= threshold && velocity >= -threshold) return;

    final values = ToyTabDestination.values;
    final index = values.indexOf(current);
    final forward = velocity > threshold;
    final nextIndex = forward ? index + 1 : index - 1;
    if (nextIndex < 0 || nextIndex >= values.length) return;

    go(
      context,
      values[nextIndex].path,
      forward ? SlideDirection.left : SlideDirection.right,
    );
  }

  static CustomTransitionPage<void> slidePage({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final direction = consumeDirection();
        if (direction == SlideDirection.none) return child;

        final begin = direction == SlideDirection.left
            ? const Offset(-1, 0)
            : const Offset(1, 0);

        return SlideTransition(
          position: animation.drive(
            Tween(begin: begin, end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: child,
        );
      },
    );
  }
}

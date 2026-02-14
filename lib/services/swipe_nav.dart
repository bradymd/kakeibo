import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

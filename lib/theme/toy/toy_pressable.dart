import 'package:flutter/material.dart';

/// Press feedback for the toy theme: on press, the element translates
/// down and its hard shadow shrinks by the same amount, 120ms ease-out.
/// This is the "toy feel" the design calls for — do not use `InkWell`
/// ripples for anything wrapped in this widget (README "Flutter
/// translation notes").
///
/// Usage: wrap any pill/card/button/key that needs press feedback and
/// build its shadow from [restOffset]/[pressedOffset] so the visual
/// shadow and the translation stay in sync.
///
///   ToyPressable(
///     onTap: ...,
///     restOffset: 5,
///     pressedOffset: 1,
///     builder: (context, offset) => Container(
///       decoration: BoxDecoration(
///         boxShadow: [BoxShadow(color: shadowColor, offset: Offset(0, offset))],
///       ),
///       transform: Matrix4.translationValues(0, restOffset - offset, 0),
///       child: ...,
///     ),
///   )
class ToyPressable extends StatefulWidget {
  const ToyPressable({
    super.key,
    required this.builder,
    this.onTap,
    this.restOffset = 5,
    this.pressedOffset = 1,
    this.duration = const Duration(milliseconds: 120),
  });

  /// Builds the child given the current shadow offset (animates from
  /// [restOffset] down to [pressedOffset] while pressed).
  final Widget Function(BuildContext context, double offset) builder;
  final VoidCallback? onTap;
  final double restOffset;
  final double pressedOffset;
  final Duration duration;

  @override
  State<ToyPressable> createState() => _ToyPressableState();
}

class _ToyPressableState extends State<ToyPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final offset = _pressed ? widget.pressedOffset : widget.restOffset;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
      onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          widget.restOffset - offset,
          0,
        ),
        child: widget.builder(context, offset),
      ),
    );
  }
}

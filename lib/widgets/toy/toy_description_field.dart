import 'package:flutter/material.dart';
import 'package:kakeibo/database/database_provider.dart' show DescriptionMatch;
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// A completely ordinary Description TextField that reports live matches
/// via [onMatchChanged] as the user types, for the caller to render as a
/// separate suggestion row below the field.
///
/// Rebuilt after the original inline-ghost-text version (a Stack: a
/// RichText behind a transparent TextField, meant to show the completion
/// after the cursor like a search bar) proved fundamentally unreliable.
/// RichText and TextField/RenderEditable cannot be relied on to produce
/// identical glyph geometry (different paragraph, padding, scroll offset,
/// cursor layout), which is what caused the reported overlapping
/// "squashed fly" text, and wrapping the TextField in a GestureDetector
/// put it in gesture-arena conflict with the TextField's own tap
/// recogniser. This version keeps the TextField itself untouched -- no
/// Stack, no wrapping GestureDetector -- and moves all suggestion
/// presentation out to a normal in-flow widget the caller controls.
class ToyDescriptionField extends StatefulWidget {
  const ToyDescriptionField({
    super.key,
    required this.controller,
    required this.findMatch,
    required this.onMatchChanged,
    this.onChanged,
  });

  final TextEditingController controller;

  /// Looks up the best match for a typed prefix. Returns null if nothing
  /// matches. Called on every change -- keep this cheap (it's a single
  /// indexed query in practice).
  final Future<DescriptionMatch?> Function(String prefix) findMatch;

  /// Called whenever the current best match changes (including to null,
  /// when nothing matches or the field is edited away from a match) --
  /// the caller uses this to show/hide a suggestion row below the field.
  final void Function(DescriptionMatch? match) onMatchChanged;

  final VoidCallback? onChanged;

  @override
  State<ToyDescriptionField> createState() => _ToyDescriptionFieldState();
}

class _ToyDescriptionFieldState extends State<ToyDescriptionField> {
  // Bumped at the very start of every listener invocation, before any
  // early return -- so a lookup in flight for a since-cleared/since-
  // changed value is discarded on arrival rather than able to resurrect a
  // stale suggestion. (The original version incremented this after the
  // early-return checks, which was itself a real bug -- Codex caught it.)
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final requestId = ++_requestId;
    widget.onChanged?.call();
    final text = widget.controller.text;
    final atEnd = widget.controller.selection.baseOffset == text.length;
    if (text.isEmpty || !atEnd) {
      widget.onMatchChanged(null);
      return;
    }
    widget.findMatch(text).then((match) {
      if (requestId != _requestId) return;
      final suggestion = match?.description ?? '';
      final isRealCompletion = match != null &&
          suggestion.toLowerCase().startsWith(text.toLowerCase()) &&
          suggestion.length > text.length;
      widget.onMatchChanged(isRealCompletion ? match : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Description',
        hintStyle: ToyTextStyles.rowTitle(fontSize: 13, color: ToyColors.placeholder),
        isDense: true,
      ),
      style: ToyTextStyles.rowTitle(fontSize: 13),
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

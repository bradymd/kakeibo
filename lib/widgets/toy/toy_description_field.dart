import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakeibo/database/database_provider.dart' show DescriptionMatch;
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// Description field with inline ghost-text completion: as the user types,
/// the rest of the best-matching past description appears greyed-out right
/// after the cursor (like a search bar), and pressing the right arrow key
/// -- or tapping the ghost text itself -- accepts it. Ignoring it (typing
/// on, or just leaving the field) does nothing; it's a pure suggestion.
///
/// Accepting a completion also reports the category that description was
/// last logged under, via [onCompletionAccepted], so the caller can
/// auto-fill Category -- but only when Category is still empty, never
/// overwriting a choice the user already made themselves.
class ToyDescriptionField extends StatefulWidget {
  const ToyDescriptionField({
    super.key,
    required this.controller,
    required this.findMatch,
    required this.onCompletionAccepted,
    this.onChanged,
  });

  final TextEditingController controller;

  /// Looks up the best match for a typed prefix. Returns null if nothing
  /// matches. Debounced/called on every change -- keep this cheap (it's a
  /// single indexed query in practice).
  final Future<DescriptionMatch?> Function(String prefix) findMatch;

  /// Called when a ghost-text suggestion is accepted, with the matched
  /// description's last-used category (empty string if it never had one).
  final void Function(String category) onCompletionAccepted;

  final VoidCallback? onChanged;

  @override
  State<ToyDescriptionField> createState() => _ToyDescriptionFieldState();
}

class _ToyDescriptionFieldState extends State<ToyDescriptionField> {
  final _focusNode = FocusNode();
  DescriptionMatch? _match;
  // Guards against a slow lookup for an earlier keystroke overwriting the
  // ghost text for a later one.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged?.call();
    final text = widget.controller.text;
    // Only offer a completion while the cursor sits at the very end --
    // editing in the middle of existing text shouldn't sprout ghost text.
    final atEnd = widget.controller.selection.baseOffset == text.length;
    if (text.isEmpty || !atEnd) {
      setState(() => _match = null);
      return;
    }
    final requestId = ++_requestId;
    widget.findMatch(text).then((match) {
      if (!mounted || requestId != _requestId) return;
      final suggestion = match?.description ?? '';
      final isRealCompletion = match != null &&
          suggestion.toLowerCase().startsWith(text.toLowerCase()) &&
          suggestion.length > text.length;
      setState(() => _match = isRealCompletion ? match : null);
    });
  }

  void _accept() {
    final match = _match;
    if (match == null) return;
    widget.controller.value = TextEditingValue(
      text: match.description,
      selection: TextSelection.collapsed(offset: match.description.length),
    );
    widget.onCompletionAccepted(match.category);
    setState(() => _match = null);
  }

  @override
  Widget build(BuildContext context) {
    final typed = widget.controller.text;
    final remainder =
        _match != null ? _match!.description.substring(typed.length) : '';

    return KeyboardListener(
      focusNode: FocusNode(skipTraversal: true, canRequestFocus: false),
      onKeyEvent: (event) {
        if (_match != null &&
            event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _accept();
        }
      },
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          if (remainder.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: RichText(
                text: TextSpan(
                  style: ToyTextStyles.rowTitle(fontSize: 13, color: Colors.transparent),
                  children: [
                    TextSpan(text: typed),
                    TextSpan(
                      text: remainder,
                      style: ToyTextStyles.rowTitle(fontSize: 13, color: ToyColors.placeholder),
                    ),
                  ],
                ),
              ),
            ),
          GestureDetector(
            onTap: remainder.isNotEmpty ? _accept : null,
            behavior: HitTestBehavior.translucent,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Description',
                hintStyle: ToyTextStyles.rowTitle(fontSize: 13, color: ToyColors.placeholder),
                isDense: true,
              ),
              style: ToyTextStyles.rowTitle(fontSize: 13),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ],
      ),
    );
  }
}

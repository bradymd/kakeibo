import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// A single settings row (README §4g): label, current value at right,
/// chevron. Row: label 13.5/800 `#5B3A45`, current value 13/800
/// `#9A7B86` at right, chevron `#C9A9B5`.
class ToySettingsRow extends StatelessWidget {
  const ToySettingsRow({
    super.key,
    required this.label,
    this.value,
    this.onTap,
    this.leading,
    this.showChevron = true,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? leading;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Expanded(
              child: Text(label, style: ToyTextStyles.rowTitle(fontSize: 13.5)),
            ),
            if (value != null) ...[
              Flexible(
                child: Text(
                  value!,
                  style: ToyTextStyles.label(fontSize: 13, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (showChevron) const Icon(Icons.chevron_right_rounded, color: ToyColors.chevron, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Group heading above a set of [ToySettingsRow]s: 11.5/900 tracked,
/// `#9A7B86`.
class ToySettingsGroupHeading extends StatelessWidget {
  const ToySettingsGroupHeading(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
      child: Text(
        title,
        style: ToyTextStyles.microLabel(fontSize: 11.5, color: ToyColors.muted2),
      ),
    );
  }
}

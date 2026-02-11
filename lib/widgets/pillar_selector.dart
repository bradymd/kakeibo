import 'package:flutter/material.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/theme/app_text_styles.dart';

class PillarSelector extends StatelessWidget {
  const PillarSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Pillar selected;
  final ValueChanged<Pillar> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: Pillar.values.map((pillar) {
        final isSelected = pillar == selected;
        return GestureDetector(
          onTap: () => onChanged(pillar),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? pillar.color.withValues(alpha: 0.15)
                  : pillar.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? pillar.color : Colors.transparent,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(pillar.icon, color: pillar.color, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pillar.label,
                        style: AppTextStyles.bodyBold.copyWith(
                          color: pillar.color,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        pillar.japanese,
                        style: AppTextStyles.japanese.copyWith(
                          fontSize: 11,
                          color: pillar.color.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

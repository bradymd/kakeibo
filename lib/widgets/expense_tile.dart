import 'package:flutter/material.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/utils/date_utils.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.formattedAmount,
    this.onTap,
    this.onDelete,
  });

  final KakeiboExpense expense;
  final String formattedAmount;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id),
      direction:
          onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete expense?'),
            content: Text(
                'Are you sure you want to delete "${expense.description}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          onDelete?.call();
        }
        return confirmed ?? false;
      },
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: expense.pillar.backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(expense.pillar.icon, color: expense.pillar.color, size: 20),
        ),
        title: Text(
          expense.description,
          style: AppTextStyles.bodyBold,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${expense.pillar.label} · ${formatDate(expense.date)}',
          style: AppTextStyles.caption,
        ),
        trailing: Text(
          formattedAmount,
          style: AppTextStyles.bodyBold.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

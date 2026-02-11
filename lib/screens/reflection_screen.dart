import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/month_calculations_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/currency_input.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';
import 'package:kakeibo/widgets/pillar_breakdown_chart.dart';
import 'package:kakeibo/widgets/sparkle_button.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final _actualSavedController = TextEditingController();
  final _howSavedController = TextEditingController();
  final _improvementsController = TextEditingController();
  final _notesController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _actualSavedController.dispose();
    _howSavedController.dispose();
    _improvementsController.dispose();
    _notesController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _initFromMonth(KakeiboMonth month) {
    if (_initialized) return;
    _initialized = true;
    final r = month.reflection;
    if (r.actualSaved > 0) {
      _actualSavedController.text = r.actualSaved.toStringAsFixed(2);
    }
    _howSavedController.text = r.howSaved;
    _improvementsController.text = r.improvements;
    _notesController.text = r.notes;
    if (r.accountBalance > 0) {
      _balanceController.text = r.accountBalance.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final pillarTotals = ref.watch(pillarTotalsProvider);
    final totalSpent = ref.watch(totalSpentProvider);
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final displayMonth = MonthHelpers.formatMonthDisplay(year, month);

    String fmt(double amount) =>
        CurrencyFormatter.format(amount, currency: currency);

    return KakeiboScaffold(
      title: 'Monthly Reflection',
      subtitle: displayMonth,
      showBackButton: true,
      body: monthAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (currentMonth) {
          _initFromMonth(currentMonth);
          final isCompleted = currentMonth.reflection.completed;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Spending breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Spending Breakdown',
                        style: AppTextStyles.subheading),
                    Text('Total: ${fmt(totalSpent)}',
                        style: AppTextStyles.caption),
                    const SizedBox(height: 12),
                    PillarBreakdownChart(
                      pillarTotals: pillarTotals,
                      formatAmount: fmt,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Q3: How much did you actually save?
              _questionCard(
                emoji: '💰',
                question: 'Q3: How much did you actually save?',
                child: CurrencyInput(
                  controller: _actualSavedController,
                  currencySymbol:
                      CurrencyFormatter.symbol(currency: currency),
                  label: 'Actual Savings',
                ),
              ),
              const SizedBox(height: 16),

              // Q4: How did you save?
              _questionCard(
                emoji: '🤔',
                question: 'Q4: What strategies helped you save?',
                child: TextFormField(
                  controller: _howSavedController,
                  decoration: const InputDecoration(
                    hintText: 'What worked well this month...',
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(height: 16),

              // Q5: How can you improve?
              _questionCard(
                emoji: '✨',
                question: 'Q5: How can you improve next month?',
                child: TextFormField(
                  controller: _improvementsController,
                  decoration: const InputDecoration(
                    hintText: 'What would you do differently...',
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(height: 16),

              // Account balance
              _questionCard(
                emoji: '🏦',
                question: 'Current account balance',
                child: CurrencyInput(
                  controller: _balanceController,
                  currencySymbol:
                      CurrencyFormatter.symbol(currency: currency),
                  label: 'Account Balance',
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  hintText: 'Any other thoughts...',
                  prefixIcon: Icon(Icons.note_rounded),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              SparkleButton(
                label:
                    isCompleted ? 'Update Reflection' : 'Complete Reflection',
                icon: Icons.check_circle_rounded,
                onPressed: () async {
                  final reflection = Reflection(
                    actualSaved: double.tryParse(
                            _actualSavedController.text) ??
                        0,
                    howSaved: _howSavedController.text.trim(),
                    improvements: _improvementsController.text.trim(),
                    notes: _notesController.text.trim(),
                    accountBalance: double.tryParse(
                            _balanceController.text) ??
                        0,
                    completed: true,
                  );
                  await ref
                      .read(kakeiboMonthsProvider.notifier)
                      .saveReflection(
                        monthId: monthId,
                        reflection: reflection,
                      );
                  if (context.mounted) context.pop();
                },
              ),

              if (isCompleted) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Reflection completed!',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _questionCard({
    required String emoji,
    required String question,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$emoji $question',
            style: AppTextStyles.bodyBold,
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

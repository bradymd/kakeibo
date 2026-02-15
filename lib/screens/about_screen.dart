import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/tip_jar_provider.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';
import 'package:kakeibo/widgets/sparkle_button.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipJar = ref.watch(tipJarProvider);

    return KakeiboScaffold(
      title: 'About',
      subtitle: 'The art of mindful spending',
      showHomeButton: true,
      centerTitle: true,
      onBack: () => context.go('/'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hero header
          Center(
            child: Column(
              children: [
                Text('家計簿',
                    style: AppTextStyles.japanese
                        .copyWith(fontSize: 36, color: AppColors.hotPink)),
                const SizedBox(height: 4),
                Text('Kakeibo',
                    style: AppTextStyles.heading
                        .copyWith(fontSize: 28, color: AppColors.hotPink)),
                const SizedBox(height: 8),
                Text('The Japanese art of mindful spending',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    )),
                const SizedBox(height: 4),
                Text('A tradition of mindfulness  心がけ',
                    style: AppTextStyles.caption.copyWith(fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _body(
            'Kakeibo (家計簿) \u2014 meaning "household financial ledger" \u2014 is a '
            'century-old Japanese method of managing money through awareness, '
            'reflection, and intention. It is not simply a way to track what you '
            'spend. It is a practice that asks you to pause, consider, and '
            'understand why you spend.\n\n'
            'In a world of one-tap payments and automated subscriptions, kakeibo '
            'invites us to slow down and reconnect with the choices we make every '
            'day about our money and, ultimately, about what we value.',
          ),

          const SizedBox(height: 24),

          _sectionHeader('Origins', '起源'),
          const SizedBox(height: 8),
          _body(
            'In 1904, Hani Motoko (羽仁もと子) \u2014 widely recognised as Japan\u2019s '
            'first female journalist \u2014 introduced the kakeibo method in a '
            'women\u2019s magazine she had founded. She created it as a practical tool '
            'to help housewives take control of their household finances at a time '
            'when women had little financial independence.\n\n'
            'What began as a household ledger became a national tradition. Over a '
            'century later, her simple philosophy of writing things down, reflecting, '
            'and improving continues to help people around the world build a '
            'healthier relationship with money.',
          ),

          const SizedBox(height: 24),

          _sectionHeader('The Four Pillars', '四つの柱'),
          const SizedBox(height: 8),
          _body(
            'At the heart of kakeibo is a beautifully simple idea: every purchase '
            'you make falls into one of four categories. By sorting your spending '
            'this way, you begin to see patterns, question habits, and make more '
            'intentional choices.',
          ),
          const SizedBox(height: 12),
          _pillarCard('必要', 'Needs',
              'The essentials you cannot do without \u2014 housing, groceries, utilities, transport, and healthcare.',
              Pillar.needs.color),
          _pillarCard('欲しい', 'Wants',
              'Things that bring enjoyment but are not essential \u2014 dining out, hobbies, new clothes, and treats.',
              Pillar.wants.color),
          _pillarCard('文化', 'Culture',
              'Spending that enriches your life \u2014 books, music, museums, theatre, courses, and streaming.',
              Pillar.culture.color),
          _pillarCard('予想外', 'Unexpected',
              'The costs that arise without warning \u2014 repairs, medical bills, and unforeseen emergencies.',
              Pillar.unexpected.color),

          const SizedBox(height: 24),

          _sectionHeader('The practice of reflection', '振り返り'),
          const SizedBox(height: 8),
          _body(
            'Kakeibo is built around four questions that you return to each month. '
            'These questions transform budgeting from a chore into a moment of '
            'honest self-reflection:',
          ),
          const SizedBox(height: 12),
          _question('How much money do I have coming in?', 'いくら収入がありますか？'),
          _question('How much would I like to save?', 'いくら貯金したいですか？'),
          _question('How much am I actually spending?', 'いくら使っていますか？'),
          _question('How can I improve?', 'どうすれば改善できますか？'),
          const SizedBox(height: 12),
          _body(
            'The beauty of this practice lies in its repetition. Month after month, '
            'these same questions gently guide you toward greater awareness. You '
            'begin to notice the impulse purchases that don\u2019t bring lasting '
            'satisfaction, the areas where you\u2019re spending well, and the goals '
            'that truly matter to you.',
          ),

          const SizedBox(height: 24),

          _sectionHeader('Why mindfulness matters', '気づき'),
          const SizedBox(height: 8),
          _body(
            'Kakeibo teaches us that saving money is not about deprivation \u2014 it '
            'is about understanding. When you take a moment to consider each '
            'purchase, to write it down and place it within a pillar, something '
            'shifts. You become an active participant in your financial life rather '
            'than a passive observer.\n\n'
            'This app carries forward Hani Motoko\u2019s original vision into the '
            'digital age. While the medium has changed from pen and paper to screen '
            'and tap, the philosophy remains the same: spend well, save well, and '
            'reflect often. Small, consistent acts of awareness lead to lasting change.',
          ),

          const SizedBox(height: 32),

          // Tip jar card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softPurple,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.vividPurple.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'If you found this app useful,\nplease consider a small donation.',
                        style: AppTextStyles.body.copyWith(height: 1.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      'assets/images/wolf-please.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                tipJar.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => _tipJarFallback(),
                  data: (tipState) {
                    if (tipState.lastSuccess) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite_rounded,
                                  color: AppColors.hotPink, size: 20),
                              const SizedBox(width: 8),
                              Text('Thank you for your support!',
                                  style: AppTextStyles.bodyBold.copyWith(
                                    color: AppColors.success,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._tipButtons(tipState, ref),
                        ],
                      );
                    }
                    if (tipState.products.isEmpty) {
                      return _tipJarFallback();
                    }
                    return Column(
                      children: [
                        if (tipState.lastError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              tipState.lastError!,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.danger),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ..._tipButtons(tipState, ref),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => launchUrl(
                    Uri.parse('https://bradymd.github.io/kakeibo/'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Kakeibo App Support Page on GitHub — ',
                          style: AppTextStyles.caption,
                        ),
                        TextSpan(
                          text: 'click here',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.vividPurple,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.vividPurple,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  static List<Widget> _tipButtons(TipJarState tipState, WidgetRef ref) {
    return tipState.products.map((product) {
      final label = product.id == 'tip_small'
          ? 'A small thank you'
          : 'Buy me a coffee';
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SparkleButton(
          label: '$label  ${product.price}',
          icon: product.id == 'tip_small'
              ? Icons.favorite_rounded
              : Icons.coffee_rounded,
          isLoading: tipState.isPurchasing,
          onPressed: tipState.isPurchasing
              ? null
              : () => ref.read(tipJarProvider.notifier).buy(product),
        ),
      );
    }).toList();
  }

  static Widget _tipJarFallback() {
    return Center(
      child: Text(
        'Tip jar is available on iOS and Android.',
        style: AppTextStyles.caption,
        textAlign: TextAlign.center,
      ),
    );
  }

  static Widget _sectionHeader(String title, String japanese) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.subheading.copyWith(
          color: AppColors.hotPink,
        )),
        Text(japanese, style: AppTextStyles.japanese.copyWith(
          fontSize: 14,
          color: AppColors.hotPink.withValues(alpha: 0.7),
        )),
      ],
    );
  }

  static Widget _body(String text) {
    return Text(text, style: AppTextStyles.body.copyWith(height: 1.6));
  }

  static Widget _pillarCard(
      String japanese, String label, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(japanese, style: AppTextStyles.japanese.copyWith(
                  fontSize: 16, color: color,
                )),
                const SizedBox(height: 2),
                Text(label, style: AppTextStyles.bodyBold.copyWith(
                  fontSize: 12, color: color,
                )),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(description, style: AppTextStyles.caption.copyWith(
                height: 1.5,
              )),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _question(String english, String japanese) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('\u2022 ', style: AppTextStyles.body.copyWith(
            color: AppColors.hotPink,
            fontWeight: FontWeight.w700,
          )),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(english, style: AppTextStyles.body.copyWith(height: 1.4)),
                Text(japanese, style: AppTextStyles.japanese.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

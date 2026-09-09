import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/tip_jar_provider.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// The gachapon-redesign About Kakeibo screen (README §4h). Tip jar
/// in-app-purchase logic reused verbatim from `about_screen.dart` — the
/// real product IDs, prices and purchase flow are untouched, only the
/// presentation changes.
class ToyAboutScreen extends ConsumerWidget {
  const ToyAboutScreen({super.key});

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipJar = ref.watch(tipJarProvider);

    return ToyScaffold(
      title: '家計簿について',
      subtitle: 'About Kakeibo',
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ToyMetrics.screenPaddingH,
          16,
          ToyMetrics.screenPaddingH,
          24,
        ),
        children: [
          ToyCard(
            child: Column(
              children: [
                Text('家計簿', style: ToyTextStyles.hero(fontSize: 30)),
                Text(
                  'KAKEIBO',
                  style: ToyTextStyles.microLabel(fontSize: 12, letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kakeibo (家計簿) — meaning "household financial ledger" — is a '
                  'century-old Japanese method of managing money through awareness, '
                  'reflection, and intention. It is not simply a way to track what you '
                  'spend. It is a practice that asks you to pause, consider, and '
                  'understand why you spend.\n\n'
                  'In a world of one-tap payments and automated subscriptions, kakeibo '
                  'invites us to slow down and reconnect with the choices we make every '
                  'day about our money and, ultimately, about what we value.',
                  style: ToyTextStyles.body(),
                ),
              ],
            ),
          ),
          const SizedBox(height: ToyMetrics.cardGap),
          _sectionCard(
            title: '起源 Origins',
            body:
                'In 1904, Hani Motoko (羽仁もと子) — widely recognised as Japan’s '
                'first female journalist — introduced the kakeibo method in a '
                'women’s magazine she had founded. She created it as a practical tool '
                'to help housewives take control of their household finances at a time '
                'when women had little financial independence.\n\n'
                'What began as a household ledger became a national tradition. Over a '
                'century later, her simple philosophy of writing things down, reflecting, '
                'and improving continues to help people around the world build a '
                'healthier relationship with money.',
          ),
          const SizedBox(height: ToyMetrics.cardGap),
          _sectionCard(
            title: '四つの柱 The Four Pillars',
            body:
                'At the heart of kakeibo is a beautifully simple idea: every purchase '
                'you make falls into one of four categories. By sorting your spending '
                'this way, you begin to see patterns, question habits, and make more '
                'intentional choices.',
            trailing: Column(
              children: [
                const SizedBox(height: 12),
                for (final pillar in Pillar.values) ...[
                  _pillarRow(pillar),
                  if (pillar != Pillar.values.last) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: ToyMetrics.cardGap),
          _sectionCard(
            title: '振り返り The practice of reflection',
            body:
                'Kakeibo is built around four questions that you return to each month. '
                'These questions transform budgeting from a chore into a moment of '
                'honest self-reflection:',
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _question('How much money do I have coming in?', 'いくら収入がありますか？'),
                _question('How much would I like to save?', 'いくら貯金したいですか？'),
                _question('How much am I actually spending?', 'いくら使っていますか？'),
                _question('How can I improve?', 'どうすれば改善できますか？'),
                const SizedBox(height: 8),
                Text(
                  'The beauty of this practice lies in its repetition. Month after month, '
                  'these same questions gently guide you toward greater awareness.',
                  style: ToyTextStyles.body(),
                ),
              ],
            ),
          ),
          const SizedBox(height: ToyMetrics.cardGap),
          _sectionCard(
            title: '気づき Why mindfulness matters',
            body:
                'Kakeibo teaches us that saving money is not about deprivation — it '
                'is about understanding. When you take a moment to consider each '
                'purchase, to write it down and place it within a pillar, something '
                'shifts. You become an active participant in your financial life rather '
                'than a passive observer.\n\n'
                'This app carries forward Hani Motoko’s original vision into the '
                'digital age. While the medium has changed from pen and paper to screen '
                'and tap, the philosophy remains the same: spend well, save well, and '
                'reflect often.',
          ),
          const SizedBox(height: ToyMetrics.cardGap),
          _TipJarCard(tipJar: tipJar),
          const SizedBox(height: ToyMetrics.cardGap),
          ToySettingsRow(
            label: 'Privacy policy',
            onTap: () => _openLink(
              context,
              'https://bradymd.github.io/kakeibo/privacy-policy.html',
            ),
          ),
          const DashedDivider(),
          ToySettingsRow(
            label: 'Report a bug on GitHub',
            onTap: () => _openLink(
              context,
              'https://github.com/bradymd/kakeibo/issues',
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required String body, Widget? trailing}) {
    return ToyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ToyTextStyles.cardTitle(fontSize: 15, color: ToyColors.brand)),
          const SizedBox(height: 8),
          Text(body, style: ToyTextStyles.body()),
          ?trailing,
        ],
      ),
    );
  }

  Widget _pillarRow(Pillar pillar) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pillar.toyFill,
        borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pillar.japanese,
                style: ToyTextStyles.rowTitle(fontSize: 13, color: pillar.toyInkOnFill),
              ),
              Text(
                pillar.label,
                style: ToyTextStyles.rowTitle(fontSize: 11, color: pillar.toyInkOnFill),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              pillar.description,
              style: ToyTextStyles.body(fontSize: 11.5, color: pillar.toyInkOnFill),
            ),
          ),
        ],
      ),
    );
  }

  Widget _question(String english, String japanese) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('・ ', style: ToyTextStyles.body(fontWeight: FontWeight.w800, color: ToyColors.brand)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(english, style: ToyTextStyles.body()),
                Text(japanese, style: ToyTextStyles.label(fontSize: 11.5, color: ToyColors.muted2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipJarCard extends ConsumerWidget {
  const _TipJarCard({required this.tipJar});

  final AsyncValue<TipJarState> tipJar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(ToyMetrics.cardPadding),
      decoration: BoxDecoration(
        color: ToyColors.goldBg,
        borderRadius: BorderRadius.circular(ToyMetrics.cardRadius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'If you found this app useful,\nplease consider a small tip.',
                  style: ToyTextStyles.body(fontWeight: FontWeight.w600, color: ToyColors.goldInk),
                ),
              ),
              const SizedBox(width: 12),
              Image.asset('assets/images/wolf-please.png', width: 76, height: 76, fit: BoxFit.contain),
            ],
          ),
          const SizedBox(height: 14),
          tipJar.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(color: ToyColors.brand),
            ),
            error: (_, _) => _fallback(),
            data: (tipState) {
              if (tipState.lastSuccess) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite_rounded, color: ToyColors.brand, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Thank you for your support!',
                          style: ToyTextStyles.rowTitle(fontSize: 13, color: ToyColors.success),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._tipButtons(tipState, ref),
                  ],
                );
              }
              if (tipState.products.isEmpty) return _fallback();
              return Column(
                children: [
                  if (tipState.lastError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        tipState.lastError!,
                        style: ToyTextStyles.label(fontSize: 11.5, color: ToyColors.danger),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ..._tipButtons(tipState, ref),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _tipButtons(TipJarState tipState, WidgetRef ref) {
    return tipState.products.map((product) {
      final label = product.id == 'tip_small' ? 'Thank You' : 'Buy Me a Coffee';
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ToyPrimaryButton(
          label: '$label  ${product.price}',
          onTap: tipState.isPurchasing ? null : () => ref.read(tipJarProvider.notifier).buy(product),
        ),
      );
    }).toList();
  }

  Widget _fallback() {
    return Text(
      'Tip jar is available on iOS and Android.',
      style: ToyTextStyles.label(fontSize: 12, color: ToyColors.goldInk),
      textAlign: TextAlign.center,
    );
  }
}

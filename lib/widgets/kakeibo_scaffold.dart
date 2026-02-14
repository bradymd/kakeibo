import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_gradients.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/kakeibo_menu_button.dart';

class KakeiboScaffold extends StatelessWidget {
  const KakeiboScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = false,
    this.showHomeButton = false,
    this.onBack,
    this.headerBottom,
    this.showMenuButton = true,
    this.centerTitle = false,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBackButton;
  final bool showHomeButton;
  final VoidCallback? onBack;
  final Widget? headerBottom;
  final bool showMenuButton;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.header,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (showHomeButton)
                          IconButton(
                            icon: const Icon(Icons.home_rounded,
                                color: Colors.white),
                            onPressed: onBack ?? () => Navigator.of(context).pop(),
                          )
                        else if (showBackButton)
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            onPressed: onBack ?? () => Navigator.of(context).pop(),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: centerTitle
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTextStyles.heading
                                    .copyWith(color: Colors.white),
                              ),
                              if (subtitle != null)
                                Text(
                                  subtitle!,
                                  style: AppTextStyles.caption
                                      .copyWith(color: Colors.white70),
                                ),
                            ],
                          ),
                        ),
                        if (actions != null) ...actions!,
                        if (showMenuButton) const KakeiboMenuButton(),
                      ],
                    ),
                    if (headerBottom != null) ...[
                      const SizedBox(height: 12),
                      headerBottom!,
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

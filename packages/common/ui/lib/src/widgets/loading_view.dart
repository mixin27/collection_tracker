import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import 'app_loading_indicator.dart';

class LoadingView extends StatelessWidget {
  final String? message;
  final double indicatorSize;

  const LoadingView({this.message, this.indicatorSize = 52, super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppLoadingIndicator(size: indicatorSize),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: AppMotion.medium,
              child: Text(
                message!,
                key: ValueKey<String>(message!),
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

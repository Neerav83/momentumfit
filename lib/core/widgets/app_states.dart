import 'package:flutter/material.dart';
import 'package:momentumfit/l10n/app_localizations.dart';

import '../theme/app_theme.dart';

class LoadingScaffold extends StatelessWidget {
  const LoadingScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.message,
    this.onRetry,
  });

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.muted),
            const SizedBox(height: 16),
            Text(
              message ?? l10n.somethingWentWrong,
              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.height = 72,
    this.width = double.infinity,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

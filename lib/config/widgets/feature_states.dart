import 'package:flutter/material.dart';

class FeatureLoading extends StatelessWidget {
  const FeatureLoading({super.key, this.label = 'Loading…'});
  final String label;
  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: _StateSurface(
            icon: Icons.sync_outlined,
            title: label,
            message: 'Preparing the latest rental workspace.',
            progress: true,
          ),
        ),
      );
}

class FeatureEmpty extends StatelessWidget {
  const FeatureEmpty(
      {super.key,
      required this.title,
      required this.message,
      this.icon = Icons.inbox_outlined,
      this.action});
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: _StateSurface(
            icon: icon,
            title: title,
            message: message,
            action: action,
          ),
        ),
      );
}

class FeatureErrorView extends StatelessWidget {
  const FeatureErrorView(
      {super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => FeatureEmpty(
        title: 'Couldn’t load this section',
        message: message,
        icon: Icons.cloud_off_outlined,
        action: FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again')),
      );
}

void showActionMessage(BuildContext context, String? message) {
  if (message == null || message.isEmpty) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class _StateSurface extends StatelessWidget {
  const _StateSurface({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.progress = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: progress
                    ? SizedBox.square(
                        dimension: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.8,
                          color: scheme.primary,
                        ),
                      )
                    : Icon(icon, size: 30, color: scheme.primary),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: .66),
                fontWeight: FontWeight.w600,
                height: 1.28,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ]),
        ),
      ),
    );
  }
}

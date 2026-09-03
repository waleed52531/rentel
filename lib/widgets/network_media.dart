import 'package:flutter/material.dart';

class NetworkMediaImage extends StatelessWidget {
  const NetworkMediaImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
  });

  final String url;
  final BoxFit fit;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: borderRadius,
        child: url.isEmpty
            ? const _MediaUnavailable()
            : Image.network(
                url,
                fit: fit,
                width: double.infinity,
                height: double.infinity,
                frameBuilder: (context, child, frame, synchronous) =>
                    synchronous || frame != null
                        ? child
                        : const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, __, ___) => const _MediaUnavailable(),
              ),
      );
}

class _MediaUnavailable extends StatelessWidget {
  const _MediaUnavailable();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 38,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      );
}

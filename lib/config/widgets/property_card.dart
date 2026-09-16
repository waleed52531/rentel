import 'package:flutter/material.dart';

import 'package:rent_settlement_app/model/entities.dart';
import 'package:rent_settlement_app/config/widgets/entity_status_badge.dart';
import 'package:rent_settlement_app/config/widgets/network_media.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard(
      {super.key,
      required this.property,
      this.onTap,
      this.trailing,
      this.showStatus = false});
  final RentalProperty property;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final location = property.city.isEmpty
        ? property.area
        : property.area.isEmpty
            ? property.city
            : '${property.area}, ${property.city}';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 148,
            width: double.infinity,
            child: Stack(children: [
              Positioned.fill(
                child: property.images.isNotEmpty
                    ? NetworkMediaImage(url: property.images.first.url)
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                        ),
                        child: Icon(
                          Icons.apartment_rounded,
                          size: 54,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: .08),
                        Colors.black.withValues(alpha: .52),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: _ImagePill(
                  icon: Icons.home_work_outlined,
                  label: property.type.displayLabel,
                ),
              ),
              if (trailing != null)
                Positioned(top: 10, right: 10, child: trailing!),
              if (showStatus)
                Positioned(
                  top: 12,
                  left: 12,
                  child: EntityStatusBadge(status: property.status),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                property.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.place_outlined, size: 16, color: scheme.secondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    property.address.isEmpty ? location : property.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: .68),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 11),
              Row(children: [
                Expanded(
                  child: Text(
                    '${property.currency} ${property.monthlyRent.toStringAsFixed(0)} / month',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
                _Metric(
                  icon: Icons.photo_library_outlined,
                  label: '${property.images.length}',
                ),
                const SizedBox(width: 8),
                _Metric(
                  icon: Icons.videocam_outlined,
                  label: '${property.videos.length}',
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ImagePill extends StatelessWidget {
  const _ImagePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .92),
          border: Border.all(color: Colors.white.withValues(alpha: .34)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: const Color(0xff8b5e3c)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xff0f172a),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ]),
        ),
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: scheme.onSurface.withValues(alpha: .72)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: .72),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ]),
      ),
    );
  }
}

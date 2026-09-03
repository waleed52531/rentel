import 'package:flutter/material.dart';

import '../models/entities.dart';
import 'entity_status_badge.dart';
import 'network_media.dart';

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
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onTap,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 126,
              width: double.infinity,
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Stack(children: [
                if (property.images.isNotEmpty)
                  Positioned.fill(
                      child: NetworkMediaImage(url: property.images.first.url))
                else
                  const Center(child: Icon(Icons.apartment_rounded, size: 54)),
                if (trailing != null)
                  Positioned(top: 8, right: 8, child: trailing!),
                if (showStatus)
                  Positioned(
                      top: 12,
                      left: 12,
                      child: EntityStatusBadge(status: property.status)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(property.address,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 9),
                    Row(children: [
                      Text(
                          'PKR ${property.monthlyRent.toStringAsFixed(0)} / month',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                      const Icon(Icons.location_city_outlined, size: 17),
                      Flexible(
                          child: Text(
                              ' ${property.city.isEmpty ? property.area : property.city}',
                              overflow: TextOverflow.ellipsis)),
                    ]),
                  ]),
            ),
          ]),
        ),
      );
}

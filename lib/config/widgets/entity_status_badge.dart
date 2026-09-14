import 'package:flutter/material.dart';

import 'package:rent_settlement_app/model/entities.dart';

class EntityStatusBadge extends StatelessWidget {
  const EntityStatusBadge({super.key, required this.status});
  final Enum status;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (status.name) {
      'published' ||
      'accepted' ||
      'active' ||
      'approved' ||
      'resolved' ||
      'completed' =>
        const Color(0xff16a34a),
      'rejected' || 'cancelled' => const Color(0xffdc2626),
      'submitted' || 'pending' || 'open' => const Color(0xffd97706),
      'underReview' || 'inProgress' => const Color(0xff2563eb),
      'frozen' => const Color(0xff0d9488),
      _ => const Color(0xff64748b),
    };
    final foreground = dark ? Color.lerp(color, Colors.white, .32)! : color;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? .18 : .11),
        border: Border.all(color: color.withValues(alpha: dark ? .42 : .24)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          status.displayLabel,
          style: TextStyle(
            color: foreground,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

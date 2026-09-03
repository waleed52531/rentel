import 'package:flutter/material.dart';

import '../models/entities.dart';

class EntityStatusBadge extends StatelessWidget {
  const EntityStatusBadge({super.key, required this.status});
  final Enum status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.name) {
      'published' ||
      'accepted' ||
      'active' ||
      'approved' ||
      'resolved' ||
      'completed' =>
        Colors.green,
      'rejected' || 'cancelled' => Colors.red,
      'submitted' || 'pending' || 'open' => Colors.orange,
      'underReview' || 'inProgress' => Colors.blue,
      'frozen' => Colors.teal,
      _ => Colors.grey,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(status.displayLabel,
            style: TextStyle(
                color: color.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

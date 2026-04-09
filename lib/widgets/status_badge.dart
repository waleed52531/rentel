import 'package:flutter/material.dart';

import '../models/entities.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final RecordStatus status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status.label),
      side: BorderSide(color: status.color.withOpacity(0.4)),
      backgroundColor: status.color.withOpacity(0.15),
      visualDensity: VisualDensity.compact,
    );
  }
}

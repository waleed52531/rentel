import 'package:flutter/material.dart';

import '../models/entities.dart';
import 'entity_status_badge.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final MonthlyRecordStatus status;

  @override
  Widget build(BuildContext context) => EntityStatusBadge(status: status);
}

import 'package:flutter/material.dart';

import 'package:rent_settlement_app/model/entities.dart';
import 'package:rent_settlement_app/config/widgets/entity_status_badge.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final MonthlyRecordStatus status;

  @override
  Widget build(BuildContext context) => EntityStatusBadge(status: status);
}

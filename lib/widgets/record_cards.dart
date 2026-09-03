import 'package:flutter/material.dart';

import '../models/entities.dart';
import 'entity_status_badge.dart';

class ApplicationCard extends StatelessWidget {
  const ApplicationCard(
      {super.key, required this.application, this.footer, this.onTap});

  final RentalApplication application;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Text(application.propertyTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                  EntityStatusBadge(status: application.status),
                ]),
                if (application.renterName.isNotEmpty)
                  Text(application.renterName),
                const SizedBox(height: 6),
                Text(application.message),
                if (application.ownerNote.isNotEmpty)
                  Text('Owner note: ${application.ownerNote}'),
                if (footer != null) ...[
                  const SizedBox(height: 10),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      );
}

class TenancyCard extends StatelessWidget {
  const TenancyCard({
    super.key,
    required this.tenancy,
    this.footer,
    this.onTap,
  });

  final Tenancy tenancy;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Text(tenancy.propertyTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                  EntityStatusBadge(status: tenancy.status),
                ]),
                if (tenancy.renterName.isNotEmpty)
                  Text('Renter: ${tenancy.renterName}'),
                Text(
                    'Rent: PKR ${tenancy.monthlyRent.toStringAsFixed(2)} · Deposit: PKR ${tenancy.deposit.toStringAsFixed(2)}'),
                Text(
                    '${_date(tenancy.startDate)}${tenancy.endDate == null ? '' : ' – ${_date(tenancy.endDate!)}'}'),
                if (tenancy.billingDay != null)
                  Text('Billing day: ${tenancy.billingDay}'),
                if (footer != null) ...[
                  const SizedBox(height: 8),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      );
}

class MonthlyRecordCard extends StatelessWidget {
  const MonthlyRecordCard({
    super.key,
    required this.record,
    this.onTap,
    this.trailing,
  });

  final MonthlyRecord record;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text('${record.month} · ${record.propertyTitle}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              '${record.currency} ${record.totalAmount.toStringAsFixed(2)} · ${record.proofCount} proof(s)${record.rejectionReason.isEmpty ? '' : '\nRejected: ${record.rejectionReason}'}'),
          trailing: trailing ?? EntityStatusBadge(status: record.status),
          onTap: onTap,
          isThreeLine: record.rejectionReason.isNotEmpty,
        ),
      );
}

class MaintenanceCard extends StatelessWidget {
  const MaintenanceCard({
    super.key,
    required this.request,
    this.onTap,
    this.footer,
  });

  final MaintenanceRequest request;
  final VoidCallback? onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Text(request.title,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                  EntityStatusBadge(status: request.status),
                ]),
                Text(
                    '${request.propertyTitle} · ${request.priority.displayLabel} priority'),
                Text(request.description,
                    maxLines: 3, overflow: TextOverflow.ellipsis),
                if (request.attachments.isNotEmpty)
                  Text('${request.attachments.length} attachment(s)'),
                if (request.timeline.isNotEmpty)
                  Text('${request.timeline.length} timeline event(s)'),
                if (footer != null) ...[
                  const SizedBox(height: 8),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      );
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

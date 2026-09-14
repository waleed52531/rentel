import 'package:flutter/material.dart';

import 'package:rent_settlement_app/model/entities.dart';
import 'package:rent_settlement_app/config/widgets/entity_status_badge.dart';

class ApplicationCard extends StatelessWidget {
  const ApplicationCard(
      {super.key, required this.application, this.footer, this.onTap});

  final RentalApplication application;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => _RecordShell(
        onTap: onTap,
        icon: Icons.assignment_outlined,
        status: EntityStatusBadge(status: application.status),
        title: application.propertyTitle,
        children: [
          if (application.renterName.isNotEmpty)
            _MetaLine(
                icon: Icons.person_outline, label: application.renterName),
          if (application.message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              application.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (application.ownerNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            _MetaLine(
              icon: Icons.sticky_note_2_outlined,
              label: 'Owner note: ${application.ownerNote}',
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
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
  Widget build(BuildContext context) => _RecordShell(
        onTap: onTap,
        icon: Icons.key_outlined,
        status: EntityStatusBadge(status: tenancy.status),
        title: tenancy.propertyTitle,
        children: [
          if (tenancy.renterName.isNotEmpty)
            _MetaLine(
              icon: Icons.person_outline,
              label: 'Renter: ${tenancy.renterName}',
            ),
          _MetaLine(
            icon: Icons.payments_outlined,
            label:
                'Rent: PKR ${tenancy.monthlyRent.toStringAsFixed(2)} - Deposit: PKR ${tenancy.deposit.toStringAsFixed(2)}',
          ),
          _MetaLine(
            icon: Icons.event_outlined,
            label:
                '${_date(tenancy.startDate)}${tenancy.endDate == null ? '' : ' - ${_date(tenancy.endDate!)}'}',
          ),
          if (tenancy.billingDay != null)
            _MetaLine(
              icon: Icons.calendar_month_outlined,
              label: 'Billing day: ${tenancy.billingDay}',
            ),
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
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
  Widget build(BuildContext context) => _RecordShell(
        onTap: onTap,
        icon: Icons.receipt_long_outlined,
        status: trailing ?? EntityStatusBadge(status: record.status),
        title: '${record.month} - ${record.propertyTitle}',
        children: [
          _MetaLine(
            icon: Icons.payments_outlined,
            label:
                '${record.currency} ${record.totalAmount.toStringAsFixed(2)}',
          ),
          _MetaLine(
            icon: Icons.attach_file_outlined,
            label: '${record.proofCount} proof(s)',
          ),
          if (record.rejectionReason.isNotEmpty)
            _MetaLine(
              icon: Icons.error_outline,
              label: 'Rejected: ${record.rejectionReason}',
            ),
        ],
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
  Widget build(BuildContext context) => _RecordShell(
        onTap: onTap,
        icon: Icons.build_outlined,
        status: EntityStatusBadge(status: request.status),
        title: request.title,
        children: [
          _MetaLine(
            icon: Icons.home_work_outlined,
            label:
                '${request.propertyTitle} - ${request.priority.displayLabel} priority',
          ),
          const SizedBox(height: 8),
          Text(
            request.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (request.attachments.isNotEmpty)
            _MetaLine(
              icon: Icons.attach_file_outlined,
              label: '${request.attachments.length} attachment(s)',
            ),
          if (request.timeline.isNotEmpty)
            _MetaLine(
              icon: Icons.timeline_outlined,
              label: '${request.timeline.length} timeline event(s)',
            ),
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      );
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

class _RecordShell extends StatelessWidget {
  const _RecordShell({
    required this.icon,
    required this.title,
    required this.status,
    required this.children,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget status;
  final List<Widget> children;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(9),
                    child: Icon(
                      icon,
                      size: 20,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                status,
              ]),
              if (children.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...children,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(
          icon,
          size: 16,
          color: scheme.secondary,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: .72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ]),
    );
  }
}

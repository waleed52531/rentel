import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rent_settlement_app/bloc/monthly_record_detail/monthly_record_detail_bloc.dart';
import 'package:rent_settlement_app/bloc/monthly_record_detail/monthly_record_detail_event.dart';
import 'package:rent_settlement_app/bloc/monthly_record_detail/monthly_record_detail_state.dart';
import 'package:rent_settlement_app/model/entities.dart';
import 'package:rent_settlement_app/repository/rental_repository.dart';
import 'package:rent_settlement_app/config/widgets/entity_status_badge.dart';
import 'package:rent_settlement_app/config/widgets/feature_states.dart';
import 'package:rent_settlement_app/config/widgets/rentra_dashboard_widgets.dart';

enum MonthlyReviewAction { approve, reject, reopen }

class MonthlyReviewDecision {
  const MonthlyReviewDecision(this.action, this.reason);
  final MonthlyReviewAction action;
  final String reason;
}

class MonthlyRecordDetailScreen extends StatelessWidget {
  const MonthlyRecordDetailScreen(
      {super.key, required this.recordId, this.canReview = false});
  final String recordId;
  final bool canReview;
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => MonthlyRecordDetailBloc(context.read<RentalRepository>())
          ..add(MonthlyRecordDetailRequested(recordId)),
        child: Scaffold(
            appBar: AppBar(title: const Text('Monthly record')),
            body:
                BlocBuilder<MonthlyRecordDetailBloc, MonthlyRecordDetailState>(
                    builder: (context, state) {
              if (state is MonthlyRecordDetailInitial ||
                  state is MonthlyRecordDetailLoading) {
                return const FeatureLoading(label: 'Loading record…');
              }
              if (state is MonthlyRecordDetailFailure) {
                return FeatureErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<MonthlyRecordDetailBloc>()
                        .add(MonthlyRecordDetailRequested(recordId)));
              }
              return _Detail(
                  record: (state as MonthlyRecordDetailLoaded).record,
                  canReview: canReview);
            })),
      );
}

class _Detail extends StatelessWidget {
  const _Detail({required this.record, required this.canReview});
  final MonthlyRecord record;
  final bool canReview;
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          RentraDetailHero(
            title: '${record.month} | ${record.propertyTitle}',
            subtitle:
                record.isFrozen ? 'Approved and frozen' : 'Monthly rent record',
            icon: Icons.receipt_long_outlined,
            status: EntityStatusBadge(status: record.status),
            metrics: [
              RentraMetricData(
                label: 'Total',
                value:
                    '${record.currency} ${record.totalAmount.toStringAsFixed(0)}',
                icon: Icons.payments_outlined,
              ),
              RentraMetricData(
                label: 'Proofs',
                value: '${record.proofs.length}',
                icon: Icons.attach_file_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          RentraInfoPanel(
            title: 'Amount breakdown',
            icon: Icons.account_balance_wallet_outlined,
            children: [
              ...record.amounts.entries.map((entry) => RentraInfoRow(
                    icon: Icons.payments_outlined,
                    label: entry.key.displayLabel,
                    value:
                        '${record.currency} ${entry.value.toStringAsFixed(2)}',
                  )),
              RentraInfoRow(
                icon: Icons.summarize_outlined,
                label: 'Total',
                value:
                    '${record.currency} ${record.totalAmount.toStringAsFixed(2)}',
              ),
            ],
          ),
          if (record.notes.isNotEmpty || record.rejectionReason.isNotEmpty)
            RentraInfoPanel(
              title: 'Notes',
              icon: Icons.notes_outlined,
              children: [
                if (record.notes.isNotEmpty)
                  RentraInfoRow(
                    icon: Icons.notes_outlined,
                    label: 'Notes',
                    value: record.notes,
                  ),
                if (record.rejectionReason.isNotEmpty)
                  RentraInfoRow(
                    icon: Icons.error_outline,
                    label: 'Rejection',
                    value: record.rejectionReason,
                  ),
              ],
            ),
          RentraInfoPanel(
            title: 'Proofs (${record.proofs.length})',
            icon: Icons.verified_outlined,
            children: record.proofs.isEmpty
                ? const [
                    RentraInfoRow(
                      icon: Icons.folder_off_outlined,
                      label: 'Files',
                      value: 'No proofs attached.',
                    )
                  ]
                : record.proofs
                    .map((proof) => RentraInfoRow(
                          icon: proof.isImage
                              ? Icons.image_outlined
                              : Icons.picture_as_pdf_outlined,
                          label: proof.originalName,
                          value:
                              '${proof.category.displayLabel} | ${proof.mimeType}',
                        ))
                    .toList(),
          ),
          if (canReview && record.status == MonthlyRecordStatus.pending) ...[
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => _reject(context),
                      child: const Text('Reject'))),
              const SizedBox(width: 8),
              Expanded(
                  child: FilledButton(
                      onPressed: () => Navigator.pop(
                          context,
                          const MonthlyReviewDecision(
                              MonthlyReviewAction.approve, '')),
                      child: const Text('Approve & freeze')))
            ])
          ],
          if (canReview && record.isFrozen) ...[
            const SizedBox(height: 18),
            OutlinedButton.icon(
                onPressed: () => _reopen(context),
                icon: const Icon(Icons.lock_open_outlined),
                label: const Text('Reopen for correction'))
          ],
        ],
      );

  Future<void> _reject(BuildContext context) async {
    final reason = TextEditingController();
    final confirm = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
                title: const Text('Reject record'),
                content: TextField(
                    controller: reason,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Reason (minimum 5 characters)')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialog, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () =>
                          Navigator.pop(dialog, reason.text.trim().length >= 5),
                      child: const Text('Reject'))
                ]));
    if (confirm == true && context.mounted) {
      Navigator.pop(
          context,
          MonthlyReviewDecision(
              MonthlyReviewAction.reject, reason.text.trim()));
    }
    reason.dispose();
  }

  Future<void> _reopen(BuildContext context) async {
    final reason = TextEditingController();
    final confirm = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
                title: const Text('Reopen record'),
                content: TextField(
                    controller: reason,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Reason (minimum 5 characters)')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialog, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () =>
                          Navigator.pop(dialog, reason.text.trim().length >= 5),
                      child: const Text('Reopen'))
                ]));
    if (confirm == true && context.mounted) {
      Navigator.pop(
          context,
          MonthlyReviewDecision(
              MonthlyReviewAction.reopen, reason.text.trim()));
    }
    reason.dispose();
  }
}

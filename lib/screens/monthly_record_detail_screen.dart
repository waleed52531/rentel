import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/monthly_record_detail/monthly_record_detail_bloc.dart';
import '../features/monthly_record_detail/monthly_record_detail_event.dart';
import '../features/monthly_record_detail/monthly_record_detail_state.dart';
import '../models/entities.dart';
import '../repositories/rental_repository.dart';
import '../widgets/entity_status_badge.dart';
import '../widgets/feature_states.dart';

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
          Row(children: [
            Expanded(
                child: Text('${record.month} · ${record.propertyTitle}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold))),
            EntityStatusBadge(status: record.status)
          ]),
          if (record.isFrozen)
            const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Approved and frozen',
                    style: TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          ...record.amounts.entries.map((entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(entry.key.displayLabel),
              trailing: Text(
                  '${record.currency} ${entry.value.toStringAsFixed(2)}'))),
          const Divider(),
          Text(
              'Total: ${record.currency} ${record.totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          if (record.notes.isNotEmpty) Text('Notes: ${record.notes}'),
          if (record.rejectionReason.isNotEmpty)
            Text('Rejection: ${record.rejectionReason}',
                style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 18),
          Text('Proofs (${record.proofs.length})',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          if (record.proofs.isEmpty)
            const Text('No proofs attached.')
          else
            ...record.proofs.map((proof) => Card(
                child: ListTile(
                    leading: Icon(proof.isImage
                        ? Icons.image_outlined
                        : Icons.picture_as_pdf_outlined),
                    title: Text(proof.originalName),
                    subtitle: Text(
                        '${proof.category.displayLabel} · ${proof.mimeType}')))),
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

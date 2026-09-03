import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/maintenance_detail/maintenance_detail_bloc.dart';
import '../features/maintenance_detail/maintenance_detail_event.dart';
import '../features/maintenance_detail/maintenance_detail_state.dart';
import '../models/entities.dart';
import '../repositories/rental_repository.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/entity_status_badge.dart';
import '../widgets/feature_states.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  const MaintenanceDetailScreen(
      {super.key, required this.requestId, required this.isOwner});
  final String requestId;
  final bool isOwner;
  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (_) => MaintenanceDetailBloc(context.read<RentalRepository>())
        ..add(MaintenanceDetailRequested(requestId)),
      child: Scaffold(
          appBar: AppBar(title: const Text('Maintenance detail')),
          body: BlocConsumer<MaintenanceDetailBloc, MaintenanceDetailState>(
              listener: (context, state) {
            if (state case MaintenanceDetailLoaded(message: final message)) {
              showActionMessage(context, message);
            }
          }, builder: (context, state) {
            if (state is MaintenanceDetailInitial ||
                state is MaintenanceDetailLoading) {
              return const FeatureLoading(label: 'Loading request…');
            }
            if (state is MaintenanceDetailFailure) {
              return FeatureErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<MaintenanceDetailBloc>()
                      .add(MaintenanceDetailRequested(requestId)));
            }
            return _Detail(
                request: (state as MaintenanceDetailLoaded).request,
                isOwner: isOwner);
          })));
}

class _Detail extends StatelessWidget {
  const _Detail({required this.request, required this.isOwner});
  final MaintenanceRequest request;
  final bool isOwner;
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(18), children: [
        Row(children: [
          Expanded(
              child: Text(request.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold))),
          EntityStatusBadge(status: request.status)
        ]),
        Text(
            '${request.propertyTitle} · ${request.priority.displayLabel} priority'),
        const SizedBox(height: 10),
        Text(request.description),
        const SizedBox(height: 18),
        Text('Attachments (${request.attachments.length})',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        if (request.attachments.isEmpty)
          const Text('No attachments.')
        else
          ...request.attachments.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_file),
              title: Text(item.originalName),
              subtitle: Text(item.mimeType))),
        const SizedBox(height: 12),
        Text('Timeline',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        if (request.timeline.isEmpty)
          const Text('No timeline entries.')
        else
          ...request.timeline.map((entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history),
              title: Text(entry.toStatus.displayLabel),
              subtitle: Text(
                  '${entry.changedBy}${entry.comment.isEmpty ? '' : ' · ${entry.comment}'}'))),
        const SizedBox(height: 14),
        OutlinedButton.icon(
            onPressed: () => _comment(context),
            icon: const Icon(Icons.comment_outlined),
            label: const Text('Add comment')),
        if (isOwner && request.allowedTransitions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
              spacing: 8,
              children: request.allowedTransitions
                  .map((status) => FilledButton.tonal(
                      onPressed: () => _changeStatus(context, status),
                      child: Text(status.displayLabel)))
                  .toList())
        ],
      ]);
  Future<void> _comment(BuildContext context) async {
    final text = TextEditingController();
    final submit = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
                title: const Text('Add timeline comment'),
                content: TextField(
                    controller: text,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Comment')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialog, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () =>
                          Navigator.pop(dialog, text.text.trim().length >= 2),
                      child: const Text('Add'))
                ]));
    if (submit == true && context.mounted) {
      context
          .read<MaintenanceDetailBloc>()
          .add(MaintenanceCommentSubmitted(request.id, text.text.trim()));
    }
    text.dispose();
  }

  Future<void> _changeStatus(
      BuildContext context, MaintenanceStatus status) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Update maintenance status',
      message: 'Move this request to ${status.displayLabel}?',
      confirmLabel: 'Update',
    );
    if (confirmed && context.mounted) {
      context
          .read<MaintenanceDetailBloc>()
          .add(MaintenanceDetailStatusChanged(request.id, status));
    }
  }
}

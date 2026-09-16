import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rent_settlement_app/bloc/maintenance_detail/maintenance_detail_bloc.dart';
import 'package:rent_settlement_app/bloc/maintenance_detail/maintenance_detail_event.dart';
import 'package:rent_settlement_app/bloc/maintenance_detail/maintenance_detail_state.dart';
import 'package:rent_settlement_app/model/entities.dart';
import 'package:rent_settlement_app/repository/rental_repository.dart';
import 'package:rent_settlement_app/config/widgets/confirmation_dialog.dart';
import 'package:rent_settlement_app/config/widgets/entity_status_badge.dart';
import 'package:rent_settlement_app/config/widgets/feature_states.dart';
import 'package:rent_settlement_app/config/widgets/rentra_dashboard_widgets.dart';

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
        RentraDetailHero(
          title: request.title,
          subtitle:
              '${request.propertyTitle} | ${request.priority.displayLabel} priority',
          icon: Icons.build_outlined,
          status: EntityStatusBadge(status: request.status),
          metrics: [
            RentraMetricData(
              label: 'Attachments',
              value: '${request.attachments.length}',
              icon: Icons.attach_file_outlined,
            ),
            RentraMetricData(
              label: 'Timeline',
              value: '${request.timeline.length}',
              icon: Icons.timeline_outlined,
            ),
          ],
        ),
        const SizedBox(height: 14),
        RentraInfoPanel(
          title: 'Request details',
          icon: Icons.description_outlined,
          children: [
            RentraInfoRow(
              icon: Icons.home_work_outlined,
              label: 'Property',
              value: request.propertyTitle,
            ),
            RentraInfoRow(
              icon: Icons.flag_outlined,
              label: 'Priority',
              value: request.priority.displayLabel,
            ),
            RentraInfoRow(
              icon: Icons.notes_outlined,
              label: 'Description',
              value: request.description,
            ),
          ],
        ),
        RentraInfoPanel(
          title: 'Attachments (${request.attachments.length})',
          icon: Icons.attach_file_outlined,
          children: request.attachments.isEmpty
              ? const [
                  RentraInfoRow(
                    icon: Icons.folder_off_outlined,
                    label: 'Files',
                    value: 'No attachments.',
                  )
                ]
              : request.attachments
                  .map((item) => RentraInfoRow(
                        icon: Icons.insert_drive_file_outlined,
                        label: item.originalName,
                        value: item.mimeType,
                      ))
                  .toList(),
        ),
        RentraInfoPanel(
          title: 'Timeline',
          icon: Icons.timeline_outlined,
          children: request.timeline.isEmpty
              ? const [
                  RentraInfoRow(
                    icon: Icons.history_toggle_off_outlined,
                    label: 'Activity',
                    value: 'No timeline entries.',
                  )
                ]
              : request.timeline
                  .map((entry) => RentraInfoRow(
                        icon: Icons.history,
                        label: entry.toStatus.displayLabel,
                        value:
                            '${entry.changedBy}${entry.comment.isEmpty ? '' : ' | ${entry.comment}'}',
                      ))
                  .toList(),
        ),
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

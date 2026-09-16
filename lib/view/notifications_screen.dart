import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rent_settlement_app/bloc/auth/auth_bloc.dart';
import 'package:rent_settlement_app/bloc/auth/auth_state.dart';
import 'package:rent_settlement_app/bloc/notifications/notifications_bloc.dart';
import 'package:rent_settlement_app/bloc/notifications/notifications_event.dart';
import 'package:rent_settlement_app/bloc/notifications/notifications_state.dart';
import 'package:rent_settlement_app/model/entities.dart';
import 'package:rent_settlement_app/repository/rental_repository.dart';
import 'package:rent_settlement_app/config/widgets/feature_states.dart';
import 'package:rent_settlement_app/config/widgets/rentra_dashboard_widgets.dart';
import 'package:rent_settlement_app/view/application_detail_screen.dart';
import 'package:rent_settlement_app/view/maintenance_detail_screen.dart';
import 'package:rent_settlement_app/view/monthly_record_detail_screen.dart';
import 'package:rent_settlement_app/view/tenancy_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => NotificationsBloc(context.read<RentalRepository>())
          ..add(const NotificationsRequested()),
        child: const _NotificationsView(),
      );
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Notifications'), actions: [
          TextButton(
              onPressed: () => context
                  .read<NotificationsBloc>()
                  .add(const AllNotificationsReadRequested()),
              child: const Text('Mark all read'))
        ]),
        body: BlocConsumer<NotificationsBloc, NotificationsState>(
          listener: (context, state) {
            if (state case NotificationsLoaded(message: final message)) {
              showActionMessage(context, message);
            }
          },
          builder: (context, state) {
            if (state is NotificationsInitial ||
                state is NotificationsLoading) {
              return const FeatureLoading(label: 'Loading notifications…');
            }
            if (state is NotificationsFailure) {
              return FeatureErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<NotificationsBloc>()
                      .add(const NotificationsRequested()));
            }
            if (state is NotificationsEmpty) {
              return const FeatureEmpty(
                  title: 'No notifications',
                  message:
                      'Updates about your Homvaro activity will appear here.',
                  icon: Icons.notifications_none);
            }
            final items = (state as NotificationsLoaded).items;
            return RefreshIndicator(
                onRefresh: () async => context
                    .read<NotificationsBloc>()
                    .add(const NotificationsRequested()),
                child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _NotificationCard(
                          item: item, onTap: () => _open(context, item));
                    }));
          },
        ),
      );

  Future<void> _open(BuildContext context, AppNotification item) async {
    if (!item.isRead) {
      context.read<NotificationsBloc>().add(NotificationReadRequested(item.id));
    }
    final maintenanceId = item.data['maintenance_request_id']?.toString();
    final monthlyRecordId = item.data['monthly_record_id']?.toString();
    final tenancyId = item.data['tenancy_id']?.toString();
    final applicationId = item.data['application_id']?.toString();
    final auth = context.read<AuthBloc>().state;
    final isOwner =
        auth is AuthAuthenticated && auth.user.role == AppRole.owner;
    Widget? destination;
    if (applicationId != null && applicationId.isNotEmpty) {
      destination = ApplicationDetailScreen(applicationId: applicationId);
    } else if (maintenanceId != null && maintenanceId.isNotEmpty) {
      destination =
          MaintenanceDetailScreen(requestId: maintenanceId, isOwner: isOwner);
    } else if (monthlyRecordId != null && monthlyRecordId.isNotEmpty) {
      destination = MonthlyRecordDetailScreen(
          recordId: monthlyRecordId, canReview: isOwner);
    } else if (tenancyId != null && tenancyId.isNotEmpty) {
      destination = TenancyDetailScreen(tenancyId: tenancyId);
    }
    if (destination != null && context.mounted) {
      await Navigator.push<void>(
          context, MaterialPageRoute(builder: (_) => destination!));
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: item.isRead
                    ? scheme.surfaceContainerHighest
                    : scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Icon(
                  item.isRead
                      ? Icons.notifications_none
                      : Icons.notifications_active_outlined,
                  color: item.isRead ? scheme.onSurfaceVariant : scheme.primary,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: item.isRead
                                      ? FontWeight.w700
                                      : FontWeight.w900,
                                ),
                      ),
                    ),
                    if (!item.isRead) ...[
                      const SizedBox(width: 8),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const SizedBox(width: 8, height: 8),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 5),
                  Text(
                    item.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: .68),
                      fontWeight: FontWeight.w600,
                      height: 1.24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  RentraInfoRow(
                    icon: Icons.schedule_outlined,
                    label: item.isRead ? 'Read update' : 'New update',
                    value: _date(item.createdAt),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/auth_bloc.dart';
import '../features/auth/auth_state.dart';
import '../features/notifications/notifications_bloc.dart';
import '../features/notifications/notifications_event.dart';
import '../features/notifications/notifications_state.dart';
import '../models/entities.dart';
import '../repositories/rental_repository.dart';
import '../widgets/feature_states.dart';
import 'application_detail_screen.dart';
import 'maintenance_detail_screen.dart';
import 'monthly_record_detail_screen.dart';
import 'tenancy_detail_screen.dart';

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
                      'Updates about your Rentra activity will appear here.',
                  icon: Icons.notifications_none);
            }
            final items = (state as NotificationsLoaded).items;
            return RefreshIndicator(
                onRefresh: () async => context
                    .read<NotificationsBloc>()
                    .add(const NotificationsRequested()),
                child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: CircleAvatar(
                            child: Icon(item.isRead
                                ? Icons.notifications_none
                                : Icons.notifications_active)),
                        title: Text(item.title,
                            style: TextStyle(
                                fontWeight: item.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold)),
                        subtitle:
                            Text('${item.body}\n${_date(item.createdAt)}'),
                        isThreeLine: true,
                        onTap: () => _open(context, item),
                      );
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

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

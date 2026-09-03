import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/application_detail/application_detail_bloc.dart';
import '../features/application_detail/application_detail_event.dart';
import '../features/application_detail/application_detail_state.dart';
import '../repositories/rental_repository.dart';
import '../widgets/entity_status_badge.dart';
import '../widgets/feature_states.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ApplicationDetailBloc(context.read<RentalRepository>())
          ..add(ApplicationDetailRequested(applicationId)),
        child: Scaffold(
          appBar: AppBar(title: const Text('Application details')),
          body: BlocBuilder<ApplicationDetailBloc, ApplicationDetailState>(
            builder: (context, state) {
              if (state is ApplicationDetailInitial ||
                  state is ApplicationDetailLoading) {
                return const FeatureLoading(label: 'Loading application…');
              }
              if (state is ApplicationDetailFailure) {
                return FeatureErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<ApplicationDetailBloc>()
                      .add(ApplicationDetailRequested(applicationId)),
                );
              }
              final application =
                  (state as ApplicationDetailLoaded).application;
              return ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        application.propertyTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    EntityStatusBadge(status: application.status),
                  ]),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline),
                    title: Text(application.renterName),
                    subtitle: Text([
                      application.renter?.email ?? '',
                      application.contactPhone,
                    ].where((value) => value.isNotEmpty).join(' · ')),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.message_outlined),
                    title: const Text('Message'),
                    subtitle: Text(application.message),
                  ),
                  if (application.ownerNote.isNotEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.rate_review_outlined),
                      title: const Text('Owner note'),
                      subtitle: Text(application.ownerNote),
                    ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule_outlined),
                    title: const Text('Submitted'),
                    subtitle: Text(_date(application.createdAt)),
                  ),
                ],
              );
            },
          ),
        ),
      );
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

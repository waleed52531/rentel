import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rent_settlement_app/bloc/application_detail/application_detail_bloc.dart';
import 'package:rent_settlement_app/bloc/application_detail/application_detail_event.dart';
import 'package:rent_settlement_app/bloc/application_detail/application_detail_state.dart';
import 'package:rent_settlement_app/repository/rental_repository.dart';
import 'package:rent_settlement_app/config/widgets/entity_status_badge.dart';
import 'package:rent_settlement_app/config/widgets/feature_states.dart';
import 'package:rent_settlement_app/config/widgets/rentra_dashboard_widgets.dart';

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
                  RentraDetailHero(
                    title: application.propertyTitle,
                    subtitle: 'Rental application review',
                    icon: Icons.assignment_outlined,
                    status: EntityStatusBadge(status: application.status),
                    metrics: [
                      RentraMetricData(
                        label: 'Applicant',
                        value: application.renterName.isEmpty
                            ? 'Renter'
                            : application.renterName,
                        icon: Icons.person_outline,
                      ),
                      RentraMetricData(
                        label: 'Submitted',
                        value: _date(application.createdAt),
                        icon: Icons.schedule_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  RentraInfoPanel(
                    title: 'Applicant profile',
                    icon: Icons.person_outline,
                    children: [
                      RentraInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Name',
                        value: application.renterName.isEmpty
                            ? 'Not provided'
                            : application.renterName,
                      ),
                      RentraInfoRow(
                        icon: Icons.mail_outline,
                        label: 'Email and phone',
                        value: [
                          application.renter?.email ?? '',
                          application.contactPhone,
                        ].where((value) => value.isNotEmpty).join(' | '),
                      ),
                    ],
                  ),
                  RentraInfoPanel(
                    title: 'Application message',
                    icon: Icons.message_outlined,
                    children: [
                      RentraInfoRow(
                        icon: Icons.chat_bubble_outline,
                        label: 'Message',
                        value: application.message.isEmpty
                            ? 'No message provided.'
                            : application.message,
                      ),
                    ],
                  ),
                  if (application.ownerNote.isNotEmpty)
                    RentraInfoPanel(
                      title: 'Owner decision note',
                      icon: Icons.rate_review_outlined,
                      children: [
                        RentraInfoRow(
                          icon: Icons.sticky_note_2_outlined,
                          label: 'Note',
                          value: application.ownerNote,
                        ),
                      ],
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

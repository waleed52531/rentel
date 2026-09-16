import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rent_settlement_app/bloc/tenancy_detail/tenancy_detail_bloc.dart';
import 'package:rent_settlement_app/bloc/tenancy_detail/tenancy_detail_event.dart';
import 'package:rent_settlement_app/bloc/tenancy_detail/tenancy_detail_state.dart';
import 'package:rent_settlement_app/repository/rental_repository.dart';
import 'package:rent_settlement_app/config/widgets/entity_status_badge.dart';
import 'package:rent_settlement_app/config/widgets/feature_states.dart';
import 'package:rent_settlement_app/config/widgets/rentra_dashboard_widgets.dart';

class TenancyDetailScreen extends StatelessWidget {
  const TenancyDetailScreen({super.key, required this.tenancyId});

  final String tenancyId;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => TenancyDetailBloc(context.read<RentalRepository>())
          ..add(TenancyDetailRequested(tenancyId)),
        child: Scaffold(
          appBar: AppBar(title: const Text('Tenancy details')),
          body: BlocBuilder<TenancyDetailBloc, TenancyDetailState>(
            builder: (context, state) {
              if (state is TenancyDetailInitial ||
                  state is TenancyDetailLoading) {
                return const FeatureLoading(label: 'Loading tenancy…');
              }
              if (state is TenancyDetailFailure) {
                return FeatureErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<TenancyDetailBloc>()
                      .add(TenancyDetailRequested(tenancyId)),
                );
              }
              final tenancy = (state as TenancyDetailLoaded).tenancy;
              return ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  RentraDetailHero(
                    title: tenancy.propertyTitle,
                    subtitle: (tenancy.property?.address.isNotEmpty ?? false)
                        ? tenancy.property!.address
                        : 'Lease and billing overview',
                    icon: Icons.key_outlined,
                    status: EntityStatusBadge(status: tenancy.status),
                    metrics: [
                      RentraMetricData(
                        label: 'Monthly rent',
                        value: 'PKR ${tenancy.monthlyRent.toStringAsFixed(0)}',
                        icon: Icons.payments_outlined,
                      ),
                      RentraMetricData(
                        label: 'Deposit',
                        value: 'PKR ${tenancy.deposit.toStringAsFixed(0)}',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  RentraInfoPanel(
                    title: 'Renter assignment',
                    icon: Icons.person_outline,
                    children: [
                      RentraInfoRow(
                        icon: Icons.person_outline,
                        label: 'Renter',
                        value: tenancy.renterName.isEmpty
                            ? 'Not assigned'
                            : tenancy.renterName,
                      ),
                      RentraInfoRow(
                        icon: Icons.home_work_outlined,
                        label: 'Property',
                        value: tenancy.propertyTitle,
                      ),
                    ],
                  ),
                  RentraInfoPanel(
                    title: 'Terms',
                    icon: Icons.fact_check_outlined,
                    children: [
                      RentraInfoRow(
                        icon: Icons.date_range_outlined,
                        label: 'Term',
                        value:
                            '${_date(tenancy.startDate)}${tenancy.endDate == null ? '' : ' - ${_date(tenancy.endDate!)}'}',
                      ),
                      if (tenancy.billingDay != null)
                        RentraInfoRow(
                          icon: Icons.event_repeat_outlined,
                          label: 'Billing day',
                          value: tenancy.billingDay.toString(),
                        ),
                      RentraInfoRow(
                        icon: Icons.payments_outlined,
                        label: 'Agreed rent and deposit',
                        value:
                            'PKR ${tenancy.monthlyRent.toStringAsFixed(2)} | PKR ${tenancy.deposit.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                  if (tenancy.notes.isNotEmpty || tenancy.endReason.isNotEmpty)
                    RentraInfoPanel(
                      title: 'Notes',
                      icon: Icons.notes_outlined,
                      children: [
                        if (tenancy.notes.isNotEmpty)
                          RentraInfoRow(
                            icon: Icons.notes_outlined,
                            label: 'Notes',
                            value: tenancy.notes,
                          ),
                        if (tenancy.endReason.isNotEmpty)
                          RentraInfoRow(
                            icon: Icons.info_outline,
                            label: 'End reason',
                            value: tenancy.endReason,
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

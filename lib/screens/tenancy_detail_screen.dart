import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/tenancy_detail/tenancy_detail_bloc.dart';
import '../features/tenancy_detail/tenancy_detail_event.dart';
import '../features/tenancy_detail/tenancy_detail_state.dart';
import '../repositories/rental_repository.dart';
import '../widgets/entity_status_badge.dart';
import '../widgets/feature_states.dart';

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
                  Row(children: [
                    Expanded(
                      child: Text(
                        tenancy.propertyTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    EntityStatusBadge(status: tenancy.status),
                  ]),
                  if (tenancy.property?.address.isNotEmpty ?? false)
                    Text(tenancy.property!.address),
                  const SizedBox(height: 14),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Renter'),
                    subtitle: Text(tenancy.renterName),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.payments_outlined),
                    title: const Text('Agreed rent and deposit'),
                    subtitle: Text(
                        'PKR ${tenancy.monthlyRent.toStringAsFixed(2)} · PKR ${tenancy.deposit.toStringAsFixed(2)}'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.date_range_outlined),
                    title: const Text('Term'),
                    subtitle: Text(
                        '${_date(tenancy.startDate)}${tenancy.endDate == null ? '' : ' – ${_date(tenancy.endDate!)}'}'),
                  ),
                  if (tenancy.billingDay != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_repeat_outlined),
                      title: const Text('Billing day'),
                      subtitle: Text(tenancy.billingDay.toString()),
                    ),
                  if (tenancy.notes.isNotEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.notes_outlined),
                      title: const Text('Notes'),
                      subtitle: Text(tenancy.notes),
                    ),
                  if (tenancy.endReason.isNotEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline),
                      title: const Text('End reason'),
                      subtitle: Text(tenancy.endReason),
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

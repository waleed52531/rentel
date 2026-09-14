import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rent_settlement_app/config/localization/app_strings.dart';
import 'package:rent_settlement_app/bloc/auth/auth_bloc.dart';
import 'package:rent_settlement_app/bloc/auth/auth_state.dart';
import 'package:rent_settlement_app/bloc/renter/applications/renter_applications_bloc.dart';
import 'package:rent_settlement_app/bloc/renter/applications/renter_applications_event.dart';
import 'package:rent_settlement_app/bloc/renter/applications/renter_applications_state.dart';
import 'package:rent_settlement_app/bloc/renter/listings/renter_listings_bloc.dart';
import 'package:rent_settlement_app/bloc/renter/listings/renter_listings_event.dart';
import 'package:rent_settlement_app/bloc/renter/listings/renter_listings_state.dart';
import 'package:rent_settlement_app/bloc/renter/listings/renter_listing_detail_bloc.dart';
import 'package:rent_settlement_app/bloc/renter/listings/renter_listing_detail_event.dart';
import 'package:rent_settlement_app/bloc/renter/listings/renter_listing_detail_state.dart';
import 'package:rent_settlement_app/bloc/renter/maintenance/renter_maintenance_bloc.dart';
import 'package:rent_settlement_app/bloc/renter/maintenance/renter_maintenance_event.dart';
import 'package:rent_settlement_app/bloc/renter/maintenance/renter_maintenance_state.dart';
import 'package:rent_settlement_app/bloc/renter/monthly_records/renter_monthly_records_bloc.dart';
import 'package:rent_settlement_app/bloc/renter/monthly_records/renter_monthly_records_event.dart';
import 'package:rent_settlement_app/bloc/renter/monthly_records/renter_monthly_records_state.dart';
import 'package:rent_settlement_app/bloc/renter/tenancy/renter_tenancy_bloc.dart';
import 'package:rent_settlement_app/bloc/renter/tenancy/renter_tenancy_event.dart';
import 'package:rent_settlement_app/bloc/renter/tenancy/renter_tenancy_state.dart';
import 'package:rent_settlement_app/model/entities.dart';
import 'package:rent_settlement_app/repository/rental_repository.dart';
import 'package:rent_settlement_app/config/widgets/feature_states.dart';
import 'package:rent_settlement_app/config/widgets/network_media.dart';
import 'package:rent_settlement_app/config/widgets/property_card.dart';
import 'package:rent_settlement_app/config/widgets/record_cards.dart';
import 'package:rent_settlement_app/config/widgets/rentra_dashboard_widgets.dart';
import 'package:rent_settlement_app/view/maintenance_detail_screen.dart';
import 'package:rent_settlement_app/view/monthly_record_detail_screen.dart';
import 'package:rent_settlement_app/view/notifications_screen.dart';
import 'package:rent_settlement_app/view/profile_screen.dart';
import 'package:rent_settlement_app/view/tenancy_detail_screen.dart';
import 'package:rent_settlement_app/view/application_detail_screen.dart';

class RenterDashboardScreen extends StatelessWidget {
  const RenterDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated || auth.user.role != AppRole.renter) {
      return const _RenterAccessDenied();
    }
    final repository = context.read<RentalRepository>();
    return MultiBlocProvider(providers: [
      BlocProvider(
          create: (_) => RenterListingsBloc(repository)
            ..add(const RenterListingsRequested())),
      BlocProvider(
          create: (_) => RenterApplicationsBloc(repository)
            ..add(const RenterApplicationsRequested())),
      BlocProvider(
          create: (_) => RenterTenancyBloc(repository)
            ..add(const RenterTenancyRequested())),
      BlocProvider(
          create: (_) => RenterMonthlyRecordsBloc(repository)
            ..add(const RenterMonthlyRecordsRequested())),
      BlocProvider(
          create: (_) => RenterMaintenanceBloc(repository)
            ..add(const RenterMaintenanceRequested())),
    ], child: const _RenterShell());
  }
}

class _RenterAccessDenied extends StatelessWidget {
  const _RenterAccessDenied();
  @override
  Widget build(BuildContext context) => Scaffold(
      body: FeatureEmpty(
          title: context.tr('Renter access required'),
          message: context.tr(
              'This screen is available only to authenticated Renter accounts.'),
          icon: Icons.lock_outline));
}

class _RenterShell extends StatefulWidget {
  const _RenterShell();
  @override
  State<_RenterShell> createState() => _RenterShellState();
}

class _RenterShellState extends State<_RenterShell> {
  int index = 0;
  static const pages = [
    RenterListingsView(),
    RenterApplicationsView(),
    RenterRentView(),
    RenterMaintenanceView()
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: RentraAppBarTitle(
              title: _title(context, index),
              subtitle: 'Renter workspace',
            ),
            actions: [
              RentraChromeButton(
                  tooltip: 'Notifications',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (_) => const NotificationsScreen())),
                  icon: Icons.notifications_outlined),
              RentraChromeButton(
                  tooltip: 'Profile',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (_) => const ProfileScreen())),
                  icon: Icons.account_circle_outlined)
            ]),
        body: SafeArea(child: IndexedStack(index: index, children: pages)),
        bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (value) {
              setState(() => index = value);
              if (value == 1) {
                context
                    .read<RenterApplicationsBloc>()
                    .add(const RenterApplicationsRequested());
              }
            },
            destinations: [
              NavigationDestination(
                  icon: const Icon(Icons.search), label: context.tr('Explore')),
              NavigationDestination(
                  icon: const Icon(Icons.assignment_outlined),
                  label: context.tr('Applications')),
              NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  label: context.tr('My rent')),
              NavigationDestination(
                  icon: const Icon(Icons.build_outlined),
                  label: context.tr('Maintenance'))
            ]),
      );

  String _title(BuildContext context, int index) => [
        context.tr('Explore listings'),
        context.tr('Applications'),
        context.tr('My rent'),
        context.tr('Maintenance'),
      ][index];
}

class RenterListingsView extends StatefulWidget {
  const RenterListingsView({super.key});
  @override
  State<RenterListingsView> createState() => _RenterListingsViewState();
}

class _RenterListingsViewState extends State<RenterListingsView> {
  final query = TextEditingController(),
      area = TextEditingController(),
      minRent = TextEditingController(),
      maxRent = TextEditingController();
  PropertyType? type;
  @override
  void dispose() {
    query.dispose();
    area.dispose();
    minRent.dispose();
    maxRent.dispose();
    super.dispose();
  }

  void load() => context.read<RenterListingsBloc>().add(RenterListingsRequested(
      query: query.text,
      area: area.text,
      type: type,
      minRent: double.tryParse(minRent.text),
      maxRent: double.tryParse(maxRent.text)));
  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: RentraDashboardHeader(
            title: 'Find your next home',
            subtitle:
                'Explore verified listings, compare rent, and apply from one place.',
            icon: Icons.travel_explore_outlined,
            metrics: [
              RentraMetricData(
                  label: 'Search', value: 'Smart', icon: Icons.search),
              RentraMetricData(
                  label: 'Applications',
                  value: 'Fast',
                  icon: Icons.assignment_outlined),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: ExpansionTile(
                title: const Text('Search & filters'),
                initiallyExpanded: true,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  TextField(
                      controller: query,
                      onSubmitted: (_) => load(),
                      decoration: const InputDecoration(
                          labelText: 'Search loaded results',
                          prefixIcon: Icon(Icons.search))),
                  const SizedBox(height: 10),
                  TextField(
                      controller: area,
                      decoration: const InputDecoration(
                          labelText: 'Area',
                          prefixIcon: Icon(Icons.location_on_outlined))),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<PropertyType?>(
                      initialValue: type,
                      decoration:
                          const InputDecoration(labelText: 'Property type'),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('Any type')),
                        ...PropertyType.values
                            .where((item) => item != PropertyType.unknown)
                            .map((item) => DropdownMenuItem(
                                value: item, child: Text(item.displayLabel)))
                      ],
                      onChanged: (value) => setState(() => type = value)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: minRent,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Min rent'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                            controller: maxRent,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Max rent')))
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                          onPressed: load,
                          icon: const Icon(Icons.tune),
                          label: const Text('Apply filters'))),
                ]),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(child: BlocBuilder<RenterListingsBloc, RenterListingsState>(
            builder: (context, state) {
          if (state is RenterListingsInitial ||
              state is RenterListingsLoading) {
            return const FeatureLoading(label: 'Finding homes…');
          }
          if (state is RenterListingsError) {
            return FeatureErrorView(message: state.message, onRetry: load);
          }
          final items = state is RenterListingsLoaded
              ? state.listings
              : <RentalProperty>[];
          if (items.isEmpty) {
            return const FeatureEmpty(
                title: 'No matching listings',
                message: 'Change your area, property type, or rent range.',
                icon: Icons.search_off);
          }
          return RefreshIndicator(
              onRefresh: () async => load(),
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    RentraSectionTitle(
                      title: 'Market snapshot',
                      subtitle: '${items.length} homes currently loaded',
                    ),
                    const SizedBox(height: 10),
                    RentraQuickActionStrip(actions: [
                      RentraQuickAction(
                        icon: Icons.apartment_outlined,
                        value:
                            '${items.where((item) => item.type == PropertyType.house).length}',
                        label: 'Houses',
                      ),
                      RentraQuickAction(
                        icon: Icons.business_outlined,
                        value:
                            '${items.where((item) => item.type == PropertyType.office).length}',
                        label: 'Offices',
                      ),
                      RentraQuickAction(
                        icon: Icons.payments_outlined,
                        value: items.isEmpty
                            ? 'PKR 0'
                            : 'PKR ${items.map((item) => item.monthlyRent).reduce((a, b) => a < b ? a : b).toStringAsFixed(0)}',
                        label: 'Lowest rent',
                      ),
                    ]),
                    const SizedBox(height: 16),
                    const RentraSectionTitle(
                      title: 'Featured listings',
                      subtitle: 'Tap a property to review and apply.',
                    ),
                    const SizedBox(height: 10),
                    ...items.map((property) => PropertyCard(
                        property: property,
                        onTap: () => _show(context, property)))
                  ]));
        })),
      ]);

  Future<void> _show(BuildContext context, RentalProperty summary) async {
    final apply = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => ListingDetailsScreen(propertyId: summary.id)));
    if (apply == true && context.mounted) _apply(context, summary);
  }

  Future<void> _apply(BuildContext context, RentalProperty property) async {
    final key = GlobalKey<FormState>();
    final message = TextEditingController(), phone = TextEditingController();
    final submit = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
                title: const Text('Apply for listing'),
                content: Form(
                    key: key,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      TextFormField(
                          controller: message,
                          maxLines: 4,
                          decoration:
                              const InputDecoration(labelText: 'Message'),
                          validator: (value) => (value?.trim().length ?? 0) < 10
                              ? 'Write at least 10 characters'
                              : null),
                      const SizedBox(height: 8),
                      TextFormField(
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                              labelText: 'Contact phone (optional)'))
                    ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialog, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () {
                        if (key.currentState?.validate() ?? false) {
                          Navigator.pop(dialog, true);
                        }
                      },
                      child: const Text('Submit'))
                ]));
    if (submit == true && context.mounted) {
      context.read<RenterApplicationsBloc>().add(RenterApplicationSubmitted(
          property.id, message.text,
          contactPhone: phone.text));
    }
    message.dispose();
    phone.dispose();
  }
}

class ListingDetailsScreen extends StatelessWidget {
  const ListingDetailsScreen({super.key, required this.propertyId});
  final String propertyId;
  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => RenterListingDetailBloc(context.read<RentalRepository>())
          ..add(RenterListingDetailRequested(propertyId)),
        child: Scaffold(
            appBar: AppBar(title: const Text('Listing details')),
            body:
                BlocBuilder<RenterListingDetailBloc, RenterListingDetailState>(
                    builder: (context, state) {
              if (state is RenterListingDetailInitial ||
                  state is RenterListingDetailLoading) {
                return const FeatureLoading(label: 'Loading listing…');
              }
              if (state is RenterListingDetailFailure) {
                return FeatureErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<RenterListingDetailBloc>()
                        .add(RenterListingDetailRequested(propertyId)));
              }
              final property = (state as RenterListingDetailLoaded).listing;
              final theme = Theme.of(context);
              final scheme = theme.colorScheme;
              return ListView(padding: const EdgeInsets.all(16), children: [
                SizedBox(
                  height: 260,
                  child: Stack(children: [
                    Positioned.fill(
                      child: property.images.isNotEmpty
                          ? PageView(
                              children: property.images
                                  .map((media) => NetworkMediaImage(
                                      url: media.url,
                                      borderRadius: BorderRadius.circular(8)))
                                  .toList())
                          : DecoratedBox(
                              decoration: BoxDecoration(
                                color: scheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.apartment_rounded,
                                  size: 70, color: scheme.onSecondaryContainer),
                            ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: .04),
                              Colors.black.withValues(alpha: .62),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(property.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              )),
                          const SizedBox(height: 6),
                          Text(
                            '${property.area}, ${property.city}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .84),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: _DetailStat(
                      icon: Icons.home_work_outlined,
                      label: 'Type',
                      value: property.type.displayLabel,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DetailStat(
                      icon: Icons.payments_outlined,
                      label: 'Rent',
                      value:
                          '${property.currency} ${property.monthlyRent.toStringAsFixed(0)}',
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                const RentraSectionTitle(
                  title: 'About this property',
                  subtitle: 'Review details before applying.',
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(property.description.isEmpty
                        ? 'No description provided.'
                        : property.description),
                  ),
                ),
                if (property.address.isNotEmpty ||
                    property.contactPhone.isNotEmpty ||
                    property.videos.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: Column(children: [
                      if (property.address.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: const Text('Address'),
                          subtitle: Text(property.address),
                        ),
                      if (property.contactPhone.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.call_outlined),
                          title: const Text('Contact'),
                          subtitle: Text(property.contactPhone),
                        ),
                      if (property.videos.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.videocam_outlined),
                          title: const Text('Walkthrough'),
                          subtitle: Text(
                              '${property.videos.length} video(s) available'),
                        ),
                    ]),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Apply for this property')),
              ]);
            })),
      );
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Icon(icon, color: scheme.secondary),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                label,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: .6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class RenterApplicationsView extends StatelessWidget {
  const RenterApplicationsView({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<RenterApplicationsBloc, RenterApplicationsState>(
          listener: (context, state) {
        if (state case RenterApplicationsLoaded(message: final message)) {
          showActionMessage(context, message);
        }
        if (state case RenterApplicationsError(message: final message)) {
          showActionMessage(context, message);
        }
      }, builder: (context, state) {
        if (state is RenterApplicationsInitial ||
            state is RenterApplicationsLoading) {
          return const FeatureLoading(label: 'Loading applications…');
        }
        if (state is RenterApplicationsError) {
          return FeatureErrorView(
              message: state.message,
              onRetry: () => context
                  .read<RenterApplicationsBloc>()
                  .add(const RenterApplicationsRequested()));
        }
        final items = state is RenterApplicationsLoaded
            ? state.applications
            : <RentalApplication>[];
        if (items.isEmpty) {
          return ListView(padding: const EdgeInsets.all(16), children: const [
            RentraDashboardHeader(
              title: 'Applications hub',
              subtitle: 'Track requests you have sent to property owners.',
              icon: Icons.assignment_outlined,
            ),
            SizedBox(height: 16),
            FeatureEmpty(
                title: 'No applications',
                message: 'Apply from a published listing.',
                icon: Icons.assignment_outlined),
          ]);
        }
        return RefreshIndicator(
            onRefresh: () async => context
                .read<RenterApplicationsBloc>()
                .add(const RenterApplicationsRequested()),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              RentraDashboardHeader(
                title: 'Applications hub',
                subtitle:
                    'Track owner responses and keep your rental requests moving.',
                icon: Icons.assignment_outlined,
                metrics: [
                  RentraMetricData(
                      label: 'Total',
                      value: '${items.length}',
                      icon: Icons.inbox_outlined),
                  RentraMetricData(
                      label: 'Pending',
                      value:
                          '${items.where((item) => item.status == ApplicationStatus.pending).length}',
                      icon: Icons.pending_actions_outlined),
                ],
              ),
              const SizedBox(height: 16),
              ...items.map((item) => ApplicationCard(
                  application: item,
                  onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ApplicationDetailScreen(
                              applicationId: item.id)))))
            ]));
      });
}

class RenterRentView extends StatelessWidget {
  const RenterRentView({super.key});
  @override
  Widget build(BuildContext context) => RefreshIndicator(
      onRefresh: () async {
        context.read<RenterTenancyBloc>().add(const RenterTenancyRequested());
        context
            .read<RenterMonthlyRecordsBloc>()
            .add(const RenterMonthlyRecordsRequested());
      },
      child: ListView(padding: const EdgeInsets.all(16), children: [
        const RentraDashboardHeader(
          title: 'Rent command center',
          subtitle:
              'Review tenancy terms, submit monthly records, and keep proofs organized.',
          icon: Icons.home_outlined,
          metrics: [
            RentraMetricData(
                label: 'Terms', value: 'Active', icon: Icons.key_outlined),
            RentraMetricData(
                label: 'Proofs', value: 'Ready', icon: Icons.attach_file),
          ],
        ),
        const SizedBox(height: 18),
        const RentraSectionTitle(
          title: 'Tenancies',
          subtitle: 'Homes currently assigned to your account.',
        ),
        const SizedBox(height: 10),
        const _TenancySection(),
        const SizedBox(height: 22),
        RentraSectionTitle(
          title: 'Monthly records',
          subtitle: 'Draft, submit, and review payment history.',
          trailing: FilledButton.icon(
              onPressed: () => _record(context),
              icon: const Icon(Icons.add),
              label: const Text('Add')),
        ),
        const SizedBox(height: 10),
        const _RecordsSection(),
        const SizedBox(height: 70),
      ]));
  Future<void> _record(BuildContext context, [MonthlyRecord? record]) async {
    final state = context.read<RenterTenancyBloc>().state;
    final active = state is RenterTenancyLoaded
        ? state.tenancies
            .where((item) => item.status == TenancyStatus.active)
            .firstOrNull
        : null;
    if (active == null) {
      showActionMessage(context, 'An active tenancy is required.');
      return;
    }
    final result = await Navigator.push<MonthlyRecordFormResult>(
        context,
        MaterialPageRoute(
            builder: (_) =>
                MonthlyRecordFormScreen(tenancy: active, record: record)));
    if (result != null && context.mounted) {
      context.read<RenterMonthlyRecordsBloc>().add(RenterMonthlyRecordSaved(
          result.record,
          submit: result.submit,
          proofPaths: result.proofPaths));
    }
  }
}

class _TenancySection extends StatelessWidget {
  const _TenancySection();
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RenterTenancyBloc, RenterTenancyState>(
          builder: (context, state) {
        if (state is RenterTenancyInitial || state is RenterTenancyLoading) {
          return const LinearProgressIndicator();
        }
        if (state is RenterTenancyError) {
          return FeatureErrorView(
              message: state.message,
              onRetry: () => context
                  .read<RenterTenancyBloc>()
                  .add(const RenterTenancyRequested()));
        }
        final items =
            state is RenterTenancyLoaded ? state.tenancies : <Tenancy>[];
        if (items.isEmpty) {
          return const Card(
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No tenancy assigned.')));
        }
        return Column(
            children: items
                .map((item) => TenancyCard(
                    tenancy: item,
                    onTap: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                TenancyDetailScreen(tenancyId: item.id)))))
                .toList());
      });
}

class _RecordsSection extends StatelessWidget {
  const _RecordsSection();
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<RenterMonthlyRecordsBloc, RenterMonthlyRecordsState>(
          listener: (context, state) {
        if (state case RenterMonthlyRecordsLoaded(message: final message)) {
          showActionMessage(context, message);
        }
        if (state case RenterMonthlyRecordsError(message: final message)) {
          showActionMessage(context, message);
        }
      }, builder: (context, state) {
        if (state is RenterMonthlyRecordsInitial ||
            state is RenterMonthlyRecordsLoading) {
          return const LinearProgressIndicator();
        }
        if (state is RenterMonthlyRecordsError) {
          return FeatureErrorView(
              message: state.message,
              onRetry: () => context
                  .read<RenterMonthlyRecordsBloc>()
                  .add(const RenterMonthlyRecordsRequested()));
        }
        final items = state is RenterMonthlyRecordsLoaded
            ? state.records
            : <MonthlyRecord>[];
        if (items.isEmpty) {
          return const Card(
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No monthly records.')));
        }
        return Column(
            children: items
                .map((item) => MonthlyRecordCard(
                    record: item,
                    trailing: item.isEditableByRenter
                        ? IconButton(
                            tooltip: 'Edit record',
                            onPressed: () => _edit(context, item),
                            icon: const Icon(Icons.edit_outlined),
                          )
                        : null,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (_) =>
                                MonthlyRecordDetailScreen(recordId: item.id)))))
                .toList());
      });

  Future<void> _edit(BuildContext context, MonthlyRecord record) async {
    final tenancyState = context.read<RenterTenancyBloc>().state;
    final tenancy = record.tenancy ??
        (tenancyState is RenterTenancyLoaded
            ? tenancyState.tenancies
                .where((item) => item.id == record.tenancyId)
                .firstOrNull
            : null);
    if (tenancy == null) {
      showActionMessage(context, 'Tenancy details are unavailable.');
      return;
    }
    final result = await Navigator.push<MonthlyRecordFormResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MonthlyRecordFormScreen(
          tenancy: tenancy,
          record: record,
        ),
      ),
    );
    if (result != null && context.mounted) {
      context.read<RenterMonthlyRecordsBloc>().add(
            RenterMonthlyRecordSaved(
              result.record,
              submit: result.submit,
              proofPaths: result.proofPaths,
            ),
          );
    }
  }
}

class MonthlyRecordFormResult {
  const MonthlyRecordFormResult(this.record, this.submit, this.proofPaths);
  final MonthlyRecord record;
  final bool submit;
  final Map<PaymentCategory, List<String>> proofPaths;
}

class MonthlyRecordFormScreen extends StatefulWidget {
  const MonthlyRecordFormScreen(
      {super.key, required this.tenancy, this.record});
  final Tenancy tenancy;
  final MonthlyRecord? record;
  @override
  State<MonthlyRecordFormScreen> createState() =>
      _MonthlyRecordFormScreenState();
}

class _MonthlyRecordFormScreenState extends State<MonthlyRecordFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController month, notes;
  final controllers = <PaymentCategory, TextEditingController>{};
  final proofPaths = <PaymentCategory, List<String>>{};
  @override
  void initState() {
    super.initState();
    month = TextEditingController(text: widget.record?.month ?? _month());
    notes = TextEditingController(text: widget.record?.notes);
    for (final category in PaymentCategory.values
        .where((item) => item != PaymentCategory.unknown)) {
      controllers[category] = TextEditingController(
          text: (widget.record?.amounts[category] ??
                  (category == PaymentCategory.rent
                      ? widget.tenancy.monthlyRent
                      : 0))
              .toStringAsFixed(2));
    }
  }

  @override
  void dispose() {
    month.dispose();
    notes.dispose();
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: Text(widget.record == null
              ? 'Create monthly record'
              : 'Edit monthly record')),
      body: Form(
          key: formKey,
          child: ListView(padding: const EdgeInsets.all(18), children: [
            TextFormField(
                controller: month,
                readOnly: widget.record != null,
                decoration:
                    const InputDecoration(labelText: 'Period (YYYY-MM)'),
                validator: (value) =>
                    RegExp(r'^\d{4}-\d{2}$').hasMatch(value ?? '')
                        ? null
                        : 'Use YYYY-MM'),
            const SizedBox(height: 14),
            Text('Amounts',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...controllers.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextFormField(
                    controller: entry.value,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: '${entry.key.displayLabel} amount'),
                    validator: (value) =>
                        (double.tryParse(value ?? '') ?? -1) < 0
                            ? 'Enter zero or a positive amount'
                            : null))),
            TextFormField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes')),
            const SizedBox(height: 16),
            Text('Proofs by category',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...PaymentCategory.values
                .where((item) => item != PaymentCategory.unknown)
                .map((category) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(category.displayLabel),
                    subtitle:
                        Text('${proofPaths[category]?.length ?? 0} selected'),
                    trailing: IconButton.filledTonal(
                        onPressed: () => _pickProofs(category),
                        icon: const Icon(Icons.attach_file)))),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => _save(false),
                      child: const Text('Save draft'))),
              const SizedBox(width: 8),
              Expanded(
                  child: FilledButton(
                      onPressed: () => _save(true),
                      child: const Text('Submit')))
            ]),
          ])));
  Future<void> _pickProofs(PaymentCategory category) async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf']);
    if (result != null && result.paths.isNotEmpty) {
      setState(() => proofPaths[category] = [
            ...?proofPaths[category],
            ...result.paths.whereType<String>()
          ]);
    }
  }

  void _save(bool submit) {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final amounts = {
      for (final entry in controllers.entries)
        entry.key: double.tryParse(entry.value.text) ?? 0
    };
    final old = widget.record;
    final record = MonthlyRecord(
        id: old?.id ?? '',
        tenancyId: widget.tenancy.id,
        month: month.text.trim(),
        amounts: amounts,
        totalAmount: amounts.values.fold(0, (sum, value) => sum + value),
        notes: notes.text.trim(),
        status: old?.status ?? MonthlyRecordStatus.draft,
        rawStatus: old?.rawStatus ?? 'draft',
        currency: old?.currency ?? 'PKR',
        isFrozen: old?.isFrozen ?? false,
        isEditableByRenter: true,
        tenancy: widget.tenancy,
        proofs: old?.proofs ?? const [],
        proofsCount: old?.proofsCount ?? 0);
    Navigator.pop(context, MonthlyRecordFormResult(record, submit, proofPaths));
  }

  String _month() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }
}

class RenterMaintenanceView extends StatelessWidget {
  const RenterMaintenanceView({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<RenterMaintenanceBloc, RenterMaintenanceState>(
          listener: (context, state) {
        if (state case RenterMaintenanceLoaded(message: final message)) {
          showActionMessage(context, message);
        }
        if (state case RenterMaintenanceError(message: final message)) {
          showActionMessage(context, message);
        }
      }, builder: (context, state) {
        if (state is RenterMaintenanceInitial ||
            state is RenterMaintenanceLoading) {
          return const FeatureLoading(label: 'Loading maintenance…');
        }
        if (state is RenterMaintenanceError) {
          return FeatureErrorView(
              message: state.message,
              onRetry: () => context
                  .read<RenterMaintenanceBloc>()
                  .add(const RenterMaintenanceRequested()));
        }
        final items = state is RenterMaintenanceLoaded
            ? state.requests
            : <MaintenanceRequest>[];
        return ListView(padding: const EdgeInsets.all(16), children: [
          RentraDashboardHeader(
            title: 'Maintenance desk',
            subtitle:
                'Raise repair requests and follow every update through resolution.',
            icon: Icons.build_outlined,
            action: FilledButton.icon(
                onPressed: () => _create(context),
                icon: const Icon(Icons.add),
                label: const Text('New')),
            metrics: [
              RentraMetricData(
                  label: 'Requests',
                  value: '${items.length}',
                  icon: Icons.build_circle_outlined),
              RentraMetricData(
                  label: 'Open',
                  value:
                      '${items.where((item) => item.status != MaintenanceStatus.completed && item.status != MaintenanceStatus.cancelled).length}',
                  icon: Icons.pending_actions_outlined),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const FeatureEmpty(
                title: 'No maintenance history',
                message: 'Create a request for an active tenancy.',
                icon: Icons.build_outlined)
          else
            ...items.map((item) => MaintenanceCard(
                  request: item,
                  onTap: () => _details(context, item),
                  footer: Text('Created ${_date(item.createdAt)}'),
                ))
        ]);
      });

  Future<void> _details(
      BuildContext context, MaintenanceRequest request) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => MaintenanceDetailScreen(
          requestId: request.id,
          isOwner: false,
        ),
      ),
    );
    if (context.mounted) {
      context
          .read<RenterMaintenanceBloc>()
          .add(const RenterMaintenanceRequested());
    }
  }

  Future<void> _create(BuildContext context) async {
    final tenancyState = context.read<RenterTenancyBloc>().state;
    final active = tenancyState is RenterTenancyLoaded
        ? tenancyState.tenancies
            .where((item) => item.status == TenancyStatus.active)
            .firstOrNull
        : null;
    if (active == null) {
      showActionMessage(context, 'An active tenancy is required.');
      return;
    }
    final title = TextEditingController(),
        description = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var priority = MaintenancePriority.medium;
    var attachments = <String>[];
    final create = await showDialog<bool>(
        context: context,
        builder: (dialog) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                    title: const Text('Maintenance request'),
                    content: SingleChildScrollView(
                        child: Form(
                            key: formKey,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                      controller: title,
                                      decoration: const InputDecoration(
                                          labelText: 'Title'),
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                              ? 'Title is required'
                                              : null),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                      controller: description,
                                      maxLines: 4,
                                      decoration: const InputDecoration(
                                          labelText:
                                              'Description (minimum 10 characters)'),
                                      validator: (value) =>
                                          (value?.trim().length ?? 0) < 10
                                              ? 'Write at least 10 characters'
                                              : null),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField(
                                      initialValue: priority,
                                      decoration: const InputDecoration(
                                          labelText: 'Priority'),
                                      items: MaintenancePriority.values
                                          .where((item) =>
                                              item !=
                                              MaintenancePriority.unknown)
                                          .map((item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(item.displayLabel)))
                                          .toList(),
                                      onChanged: (value) => setDialogState(
                                          () => priority = value!)),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                      onPressed: () async {
                                        final result = await FilePicker.platform
                                            .pickFiles(
                                                allowMultiple: true,
                                                type: FileType.custom,
                                                allowedExtensions: const [
                                              'jpg',
                                              'jpeg',
                                              'png',
                                              'webp',
                                              'pdf'
                                            ]);
                                        if (result != null &&
                                            result.paths.isNotEmpty) {
                                          setDialogState(() => attachments =
                                              result.paths
                                                  .whereType<String>()
                                                  .toList());
                                        }
                                      },
                                      icon: const Icon(Icons.attach_file),
                                      label: Text(
                                          '${attachments.length} attachment(s)'))
                                ]))),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(dialog, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? false) {
                              Navigator.pop(dialog, true);
                            }
                          },
                          child: const Text('Create'))
                    ])));
    if (create == true && context.mounted) {
      context.read<RenterMaintenanceBloc>().add(RenterMaintenanceCreated(
          tenancyId: active.id,
          title: title.text,
          description: description.text,
          priority: priority,
          attachmentPaths: attachments));
    }
    title.dispose();
    description.dispose();
  }
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

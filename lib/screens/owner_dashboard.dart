import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/localization/app_strings.dart';
import '../features/auth/auth_bloc.dart';
import '../features/auth/auth_state.dart';
import '../features/owner/applications/owner_applications_bloc.dart';
import '../features/owner/applications/owner_applications_event.dart';
import '../features/owner/applications/owner_applications_state.dart';
import '../features/owner/maintenance/owner_maintenance_bloc.dart';
import '../features/owner/maintenance/owner_maintenance_event.dart';
import '../features/owner/maintenance/owner_maintenance_state.dart';
import '../features/owner/monthly_records/owner_monthly_records_bloc.dart';
import '../features/owner/monthly_records/owner_monthly_records_event.dart';
import '../features/owner/monthly_records/owner_monthly_records_state.dart';
import '../features/owner/properties/owner_properties_bloc.dart';
import '../features/owner/properties/owner_properties_event.dart';
import '../features/owner/properties/owner_properties_state.dart';
import '../features/owner/properties/owner_property_detail_bloc.dart';
import '../features/owner/properties/owner_property_detail_event.dart';
import '../features/owner/properties/owner_property_detail_state.dart';
import '../features/owner/tenancies/owner_tenancies_bloc.dart';
import '../features/owner/tenancies/owner_tenancies_event.dart';
import '../features/owner/tenancies/owner_tenancies_state.dart';
import '../models/entities.dart';
import '../repositories/rental_repository.dart';
import '../widgets/entity_status_badge.dart';
import '../widgets/feature_states.dart';
import '../widgets/network_media.dart';
import '../widgets/property_card.dart';
import '../widgets/record_cards.dart';
import 'maintenance_detail_screen.dart';
import 'monthly_record_detail_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'tenancy_detail_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated || auth.user.role != AppRole.owner) {
      return const _AccessDenied();
    }
    final repository = context.read<RentalRepository>();
    return MultiBlocProvider(providers: [
      BlocProvider(
          create: (_) => OwnerPropertiesBloc(repository)
            ..add(const OwnerPropertiesRequested())),
      BlocProvider(
          create: (_) => OwnerApplicationsBloc(repository)
            ..add(const OwnerApplicationsRequested())),
      BlocProvider(
          create: (_) => OwnerTenanciesBloc(repository)
            ..add(const OwnerTenanciesRequested())),
      BlocProvider(
          create: (_) => OwnerMonthlyRecordsBloc(repository)
            ..add(const OwnerMonthlyRecordsRequested())),
      BlocProvider(
          create: (_) => OwnerMaintenanceBloc(repository)
            ..add(const OwnerMaintenanceRequested())),
    ], child: const _OwnerShell());
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();
  @override
  Widget build(BuildContext context) => Scaffold(
      body: FeatureEmpty(
          title: context.tr('Owner access required'),
          message: context.tr(
              'This screen is available only to authenticated Owner accounts.'),
          icon: Icons.lock_outline));
}

class _OwnerShell extends StatefulWidget {
  const _OwnerShell();
  @override
  State<_OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<_OwnerShell> {
  int index = 0;
  static const pages = [
    OwnerPropertiesView(),
    OwnerApplicationsView(),
    OwnerTenanciesView(),
    OwnerMonthlyRecordsView(),
    OwnerMaintenanceView()
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(_title(context, index)), actions: [
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const NotificationsScreen())),
              icon: const Icon(Icons.notifications_outlined)),
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const ProfileScreen())),
              icon: const Icon(Icons.account_circle_outlined)),
        ]),
        body: SafeArea(child: IndexedStack(index: index, children: pages)),
        bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (value) => setState(() => index = value),
            destinations: [
              NavigationDestination(
                  icon: const Icon(Icons.home_work_outlined),
                  label: context.tr('Properties')),
              NavigationDestination(
                  icon: const Icon(Icons.assignment_outlined),
                  label: context.tr('Applications')),
              NavigationDestination(
                  icon: const Icon(Icons.key_outlined),
                  label: context.tr('Tenancies')),
              NavigationDestination(
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: context.tr('Records')),
              NavigationDestination(
                  icon: const Icon(Icons.build_outlined),
                  label: context.tr('Maintenance')),
            ]),
      );

  String _title(BuildContext context, int index) => [
        context.tr('Properties'),
        context.tr('Applications'),
        context.tr('Tenancies'),
        context.tr('Monthly records'),
        context.tr('Maintenance'),
      ][index];
}

class OwnerPropertiesView extends StatelessWidget {
  const OwnerPropertiesView({super.key});
  Future<void> _edit(BuildContext context, [RentalProperty? property]) async {
    final result = await Navigator.push<PropertyFormResult>(
        context,
        MaterialPageRoute(
            builder: (_) => property == null
                ? const PropertyFormScreen()
                : OwnerPropertyEditorScreen(propertyId: property.id)));
    if (result != null && context.mounted) {
      context.read<OwnerPropertiesBloc>().add(OwnerPropertySaved(
          result.property,
          imagePaths: result.imagePaths,
          videoPaths: result.videoPaths));
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<OwnerPropertiesBloc, OwnerPropertiesState>(
        listener: (context, state) {
          if (state case OwnerPropertiesLoaded(message: final message)) {
            showActionMessage(context, message);
          }
          if (state case OwnerPropertiesError(message: final message)) {
            showActionMessage(context, message);
          }
        },
        builder: (context, state) {
          if (state is OwnerPropertiesInitial ||
              state is OwnerPropertiesLoading) {
            return const FeatureLoading(label: 'Loading properties…');
          }
          if (state is OwnerPropertiesError) {
            return FeatureErrorView(
                message: state.message,
                onRetry: () => context
                    .read<OwnerPropertiesBloc>()
                    .add(const OwnerPropertiesRequested()));
          }
          final items = state is OwnerPropertiesLoaded
              ? state.properties
              : <RentalProperty>[];
          return RefreshIndicator(
              onRefresh: () async => context
                  .read<OwnerPropertiesBloc>()
                  .add(const OwnerPropertiesRequested()),
              child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text('${items.length} properties',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold))),
                      FilledButton.icon(
                          onPressed: () => _edit(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add'))
                    ]),
                    const SizedBox(height: 12),
                    if (items.isEmpty)
                      const FeatureEmpty(
                          title: 'No properties',
                          message:
                              'Create a property and upload the required gallery to begin.',
                          icon: Icons.home_work_outlined)
                    else
                      ...items.map((property) => PropertyCard(
                          property: property,
                          showStatus: true,
                          onTap: () => _edit(context, property),
                          trailing: PopupMenuButton<PublicationStatus>(
                            tooltip: 'Publication',
                            onSelected: (status) => context
                                .read<OwnerPropertiesBloc>()
                                .add(OwnerPropertySaved(property.copyWith(
                                    publicationStatus: status))),
                            itemBuilder: (_) => [
                              if (property.publicationStatus !=
                                  PublicationStatus.published)
                                const PopupMenuItem(
                                    value: PublicationStatus.published,
                                    child: Text('Publish')),
                              if (property.publicationStatus !=
                                  PublicationStatus.draft)
                                const PopupMenuItem(
                                    value: PublicationStatus.draft,
                                    child: Text('Unpublish'))
                            ],
                          ))),
                  ]));
        },
      );
}

class PropertyFormResult {
  const PropertyFormResult(this.property, this.imagePaths, this.videoPaths);
  final RentalProperty property;
  final List<String> imagePaths;
  final List<String> videoPaths;
}

class OwnerPropertyEditorScreen extends StatelessWidget {
  const OwnerPropertyEditorScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => OwnerPropertyDetailBloc(context.read<RentalRepository>())
          ..add(OwnerPropertyDetailRequested(propertyId)),
        child: BlocBuilder<OwnerPropertyDetailBloc, OwnerPropertyDetailState>(
          builder: (context, state) {
            if (state is OwnerPropertyDetailInitial ||
                state is OwnerPropertyDetailLoading) {
              return const Scaffold(
                  body: FeatureLoading(label: 'Loading property…'));
            }
            if (state is OwnerPropertyDetailFailure) {
              return Scaffold(
                appBar: AppBar(title: const Text('Property details')),
                body: FeatureErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<OwnerPropertyDetailBloc>()
                      .add(OwnerPropertyDetailRequested(propertyId)),
                ),
              );
            }
            return PropertyFormScreen(
                property: (state as OwnerPropertyDetailLoaded).property);
          },
        ),
      );
}

class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen({super.key, this.property});
  final RentalProperty? property;
  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController title,
      rent,
      area,
      city,
      address,
      description,
      contactName,
      contactPhone,
      contactEmail;
  late PropertyType type;
  late RentalMode rentalMode;
  late PropertyStatus status;
  late PublicationStatus publication;
  final imagePaths = <String>[];
  final videoPaths = <String>[];
  @override
  void initState() {
    super.initState();
    final p = widget.property;
    title = TextEditingController(text: p?.title);
    rent = TextEditingController(text: p?.monthlyRent.toStringAsFixed(2));
    area = TextEditingController(text: p?.area);
    city = TextEditingController(text: p?.city);
    address = TextEditingController(text: p?.address);
    description = TextEditingController(text: p?.description);
    contactName = TextEditingController(text: p?.contactName);
    contactPhone = TextEditingController(text: p?.contactPhone);
    contactEmail = TextEditingController(text: p?.contactEmail);
    type = p?.type == PropertyType.unknown
        ? PropertyType.house
        : p?.type ?? PropertyType.house;
    rentalMode = p?.rentalMode == RentalMode.unknown
        ? RentalMode.whole
        : p?.rentalMode ?? RentalMode.whole;
    status = p?.status == PropertyStatus.unknown
        ? PropertyStatus.available
        : p?.status ?? PropertyStatus.available;
    publication = p?.publicationStatus == PublicationStatus.unknown
        ? PublicationStatus.draft
        : p?.publicationStatus ?? PublicationStatus.draft;
  }

  @override
  void dispose() {
    for (final controller in [
      title,
      rent,
      area,
      city,
      address,
      description,
      contactName,
      contactPhone,
      contactEmail
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: Text(
              widget.property == null ? 'Create property' : 'Edit property')),
      body: Form(
          key: formKey,
          child: ListView(padding: const EdgeInsets.all(18), children: [
            DropdownButtonFormField(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Property type'),
                items: PropertyType.values
                    .where((item) => item != PropertyType.unknown)
                    .map((item) => DropdownMenuItem(
                        value: item, child: Text(item.displayLabel)))
                    .toList(),
                onChanged: (value) => setState(() => type = value!)),
            const SizedBox(height: 10),
            DropdownButtonFormField(
                initialValue: rentalMode,
                decoration:
                    const InputDecoration(labelText: 'Rental arrangement'),
                items: RentalMode.values
                    .where((item) => item != RentalMode.unknown)
                    .map((item) => DropdownMenuItem(
                        value: item, child: Text(item.displayLabel)))
                    .toList(),
                onChanged: (value) => setState(() => rentalMode = value!)),
            const SizedBox(height: 10),
            _field(title, 'Title', required: true),
            const SizedBox(height: 10),
            if (rentalMode != RentalMode.byFloor) ...[
              _field(rent, 'Rent amount', required: true, number: true),
              const SizedBox(height: 10)
            ],
            Row(children: [
              Expanded(child: _field(area, 'Area', required: true)),
              const SizedBox(width: 10),
              Expanded(child: _field(city, 'City'))
            ]),
            const SizedBox(height: 10),
            _field(address, 'Full address', required: true),
            const SizedBox(height: 10),
            _field(description, 'Description', lines: 4),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: DropdownButtonFormField(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Occupancy'),
                      items: PropertyStatus.values
                          .where((item) => item != PropertyStatus.unknown)
                          .map((item) => DropdownMenuItem(
                              value: item, child: Text(item.displayLabel)))
                          .toList(),
                      onChanged: (value) => setState(() => status = value!))),
              const SizedBox(width: 10),
              Expanded(
                  child: DropdownButtonFormField(
                      initialValue: publication,
                      decoration:
                          const InputDecoration(labelText: 'Publication'),
                      items: PublicationStatus.values
                          .where((item) => item != PublicationStatus.unknown)
                          .map((item) => DropdownMenuItem(
                              value: item, child: Text(item.displayLabel)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => publication = value!)))
            ]),
            const SizedBox(height: 18),
            Text('Contact',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _field(contactName, 'Contact name'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _field(contactPhone, 'Phone')),
              const SizedBox(width: 10),
              Expanded(child: _field(contactEmail, 'Email'))
            ]),
            const SizedBox(height: 18),
            Text('Gallery',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(
                '${widget.property?.images.length ?? 0} existing · ${imagePaths.length} selected (minimum 3 total)'),
            if (widget.property?.images.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.property!.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) => SizedBox(
                    width: 124,
                    child: NetworkMediaImage(
                      url: widget.property!.images[index].url,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
            if (widget.property?.videos.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.property!.videos
                      .map((video) => Chip(
                            avatar: const Icon(Icons.play_circle_outline),
                            label: Text(video.mimeType.isEmpty
                                ? 'Existing video'
                                : video.mimeType),
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Add images')),
              OutlinedButton.icon(
                  onPressed: _pickVideos,
                  icon: const Icon(Icons.video_library_outlined),
                  label: const Text('Add videos'))
            ]),
            if (imagePaths.isNotEmpty || videoPaths.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                      '${imagePaths.length} image(s), ${videoPaths.length} video(s) ready to upload')),
            const SizedBox(height: 22),
            FilledButton(onPressed: _save, child: const Text('Save property')),
          ])));

  Widget _field(TextEditingController controller, String label,
          {bool required = false, bool number = false, int lines = 1}) =>
      TextFormField(
          controller: controller,
          maxLines: lines,
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true)
              : null,
          decoration: InputDecoration(labelText: label),
          validator: required
              ? (value) => value == null || value.trim().isEmpty
                  ? '$label is required'
                  : null
              : null);
  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp']);
    if (result != null && result.paths.isNotEmpty) {
      setState(() => imagePaths.addAll(result.paths.whereType<String>()));
    }
  }

  Future<void> _pickVideos() async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: const ['mp4', 'mov', 'webm']);
    if (result != null && result.paths.isNotEmpty) {
      setState(() => videoPaths.addAll(result.paths.whereType<String>()));
    }
  }

  void _save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final totalImages =
        (widget.property?.images.length ?? 0) + imagePaths.length;
    if (totalImages < 3) {
      showActionMessage(
          context, 'Select at least ${3 - totalImages} more image(s).');
      return;
    }
    final old = widget.property;
    final property = RentalProperty(
        id: old?.id ?? '',
        title: title.text.trim(),
        type: type,
        rawType: enumWireValue(type),
        rentalMode: rentalMode,
        rawRentalMode: enumWireValue(rentalMode),
        monthlyRent: double.tryParse(rent.text) ?? 0,
        area: area.text.trim(),
        city: city.text.trim(),
        address: address.text.trim(),
        description: description.text.trim(),
        status: status,
        rawStatus: enumWireValue(status),
        publicationStatus: publication,
        rawPublicationStatus: enumWireValue(publication),
        contactName: contactName.text.trim(),
        contactPhone: contactPhone.text.trim(),
        contactEmail: contactEmail.text.trim(),
        images: old?.images ?? const [],
        videos: old?.videos ?? const [],
        floors: old?.floors ?? const [],
        isRentable: rentalMode == RentalMode.whole,
        currency: old?.currency ?? 'PKR');
    Navigator.pop(
        context, PropertyFormResult(property, imagePaths, videoPaths));
  }
}

class OwnerApplicationsView extends StatelessWidget {
  const OwnerApplicationsView({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<OwnerApplicationsBloc, OwnerApplicationsState>(
          listener: (context, state) {
        if (state case OwnerApplicationsLoaded(message: final message)) {
          showActionMessage(context, message);
        }
        if (state case OwnerApplicationsError(message: final message)) {
          showActionMessage(context, message);
        }
      }, builder: (context, state) {
        if (state is OwnerApplicationsInitial ||
            state is OwnerApplicationsLoading) {
          return const FeatureLoading(label: 'Loading applications…');
        }
        if (state is OwnerApplicationsError) {
          return FeatureErrorView(
              message: state.message,
              onRetry: () => context
                  .read<OwnerApplicationsBloc>()
                  .add(const OwnerApplicationsRequested()));
        }
        final items = state is OwnerApplicationsLoaded
            ? state.applications
            : <RentalApplication>[];
        if (items.isEmpty) {
          return const FeatureEmpty(
              title: 'No applications',
              message: 'Applications for your listings will appear here.',
              icon: Icons.assignment_outlined);
        }
        return RefreshIndicator(
            onRefresh: () async => context
                .read<OwnerApplicationsBloc>()
                .add(const OwnerApplicationsRequested()),
            child: ListView(
                padding: const EdgeInsets.all(16),
                children: items
                    .map((item) => Card(
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(
                                        child: Text(item.propertyTitle,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    EntityStatusBadge(status: item.status)
                                  ]),
                                  Text(
                                      '${item.renterName} · ${item.contactPhone}'),
                                  const SizedBox(height: 6),
                                  Text(item.message),
                                  if (item.ownerNote.isNotEmpty)
                                    Text('Owner note: ${item.ownerNote}'),
                                  const SizedBox(height: 10),
                                  if (item.status ==
                                          ApplicationStatus.pending ||
                                      item.status == ApplicationStatus.reviewed)
                                    Row(children: [
                                      Expanded(
                                          child: OutlinedButton(
                                              onPressed: () => _decide(
                                                  context,
                                                  item,
                                                  ApplicationStatus.rejected),
                                              child: const Text('Reject'))),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: FilledButton(
                                              onPressed: () => _decide(
                                                  context,
                                                  item,
                                                  ApplicationStatus.accepted),
                                              child: const Text('Accept')))
                                    ]),
                                  if (item.status == ApplicationStatus.accepted)
                                    Align(
                                        alignment: Alignment.centerRight,
                                        child: FilledButton.tonalIcon(
                                            onPressed: () => context
                                                .read<OwnerTenanciesBloc>()
                                                .add(OwnerTenancyAssigned(
                                                    item.id, DateTime.now())),
                                            icon: const Icon(Icons.key),
                                            label:
                                                const Text('Create tenancy'))),
                                ]))))
                    .toList()));
      });
  Future<void> _decide(BuildContext context, RentalApplication item,
      ApplicationStatus status) async {
    final note = TextEditingController();
    final submit = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
                title: Text('${status.displayLabel} application'),
                content: TextField(
                    controller: note,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Owner note (optional)')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialog, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialog, true),
                      child: const Text('Confirm'))
                ]));
    if (submit == true && context.mounted) {
      context
          .read<OwnerApplicationsBloc>()
          .add(OwnerApplicationDecided(item.id, status, ownerNote: note.text));
    }
    note.dispose();
  }
}

class OwnerTenanciesView extends StatelessWidget {
  const OwnerTenanciesView({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<OwnerTenanciesBloc, OwnerTenanciesState>(
          listener: (context, state) {
        if (state case OwnerTenanciesLoaded(message: final message)) {
          showActionMessage(context, message);
        }
        if (state
            case OwnerTenanciesLoaded(
              temporaryPassword: final String password
            )) {
          _showTemporaryPassword(context, password);
        }
        if (state case OwnerTenanciesError(message: final message)) {
          showActionMessage(context, message);
        }
      }, builder: (context, state) {
        if (state is OwnerTenanciesInitial || state is OwnerTenanciesLoading) {
          return const FeatureLoading(label: 'Loading tenancies…');
        }
        if (state is OwnerTenanciesError) {
          return FeatureErrorView(
              message: state.message,
              onRetry: () => context
                  .read<OwnerTenanciesBloc>()
                  .add(const OwnerTenanciesRequested()));
        }
        final items =
            state is OwnerTenanciesLoaded ? state.tenancies : <Tenancy>[];
        if (items.isEmpty) {
          return FeatureEmpty(
              title: 'No tenancies',
              message: 'Accept an application to assign an existing renter.',
              icon: Icons.key_outlined,
              action: FilledButton.icon(
                  onPressed: () => _create(context),
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Assign new renter')));
        }
        return RefreshIndicator(
            onRefresh: () async => context
                .read<OwnerTenanciesBloc>()
                .add(const OwnerTenanciesRequested()),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                      onPressed: () => _create(context),
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text('Assign new renter'))),
              const SizedBox(height: 10),
              ...items.map((item) => TenancyCard(
                    tenancy: item,
                    onTap: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                TenancyDetailScreen(tenancyId: item.id))),
                    footer: item.status == TenancyStatus.active
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () => _edit(context, item),
                                  child: const Text('Edit terms')),
                              TextButton(
                                  onPressed: () => _end(context, item),
                                  child: const Text('End tenancy')),
                            ],
                          )
                        : null,
                  ))
            ]));
      });

  Future<void> _create(BuildContext context) async {
    final propertyState = context.read<OwnerPropertiesBloc>().state;
    final topLevel = propertyState is OwnerPropertiesLoaded
        ? propertyState.properties
        : <RentalProperty>[];
    final properties = <RentalProperty>[
      for (final property in topLevel) ...[
        if (property.isRentable && property.status == PropertyStatus.available)
          property,
        ...property.floors.where((floor) =>
            floor.isRentable && floor.status == PropertyStatus.available),
      ]
    ];
    if (properties.isEmpty) {
      showActionMessage(context, 'An available rentable property is required.');
      return;
    }
    final result = await Navigator.push<NewRenterTenancyFormResult>(
      context,
      MaterialPageRoute(
          builder: (_) => NewRenterTenancyScreen(properties: properties)),
    );
    if (result != null && context.mounted) {
      context.read<OwnerTenanciesBloc>().add(OwnerNewRenterTenancyCreated(
            propertyId: result.property.id,
            renterName: result.renterName,
            renterEmail: result.renterEmail,
            renterPhone: result.renterPhone,
            startDate: result.startDate,
            endDate: result.endDate,
            agreedRent: result.agreedRent,
            deposit: result.deposit,
            billingDay: result.billingDay,
            notes: result.notes,
          ));
    }
  }

  Future<void> _showTemporaryPassword(
      BuildContext context, String password) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialog) => AlertDialog(
        title: const Text('Temporary password'),
        content: SelectableText(
            'Give this one-time password to the new Renter:\n\n$password\n\nIt is not stored and will not be shown again.'),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(dialog),
              child: const Text('I have saved it'))
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, Tenancy item) async {
    final start = TextEditingController(text: _apiDate(item.startDate));
    final end = TextEditingController(
        text: item.endDate == null ? '' : _apiDate(item.endDate!));
    final rent =
        TextEditingController(text: item.monthlyRent.toStringAsFixed(2));
    final deposit =
        TextEditingController(text: item.deposit.toStringAsFixed(2));
    final billing =
        TextEditingController(text: item.billingDay?.toString() ?? '');
    final notes = TextEditingController(text: item.notes);
    final save = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
              title: const Text('Edit tenancy terms'),
              content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: start,
                    decoration: const InputDecoration(
                        labelText: 'Start date (YYYY-MM-DD)')),
                const SizedBox(height: 8),
                TextField(
                    controller: end,
                    decoration: const InputDecoration(
                        labelText: 'End date (optional)')),
                const SizedBox(height: 8),
                TextField(
                    controller: rent,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Agreed rent')),
                const SizedBox(height: 8),
                TextField(
                    controller: deposit,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Deposit')),
                const SizedBox(height: 8),
                TextField(
                    controller: billing,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Billing day (1–31)')),
                const SizedBox(height: 8),
                TextField(
                    controller: notes,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Notes')),
              ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialog, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(dialog, true),
                    child: const Text('Save'))
              ],
            ));
    if (save == true && context.mounted) {
      context.read<OwnerTenanciesBloc>().add(OwnerTenancyUpdated(Tenancy(
            id: item.id,
            status: item.status,
            rawStatus: item.rawStatus,
            startDate: DateTime.tryParse(start.text) ?? item.startDate,
            endDate:
                end.text.trim().isEmpty ? null : DateTime.tryParse(end.text),
            monthlyRent: double.tryParse(rent.text) ?? item.monthlyRent,
            deposit: double.tryParse(deposit.text) ?? item.deposit,
            billingDay: int.tryParse(billing.text),
            notes: notes.text,
            endedAt: item.endedAt,
            endReason: item.endReason,
            property: item.property,
            renter: item.renter,
            monthlyRecordsCount: item.monthlyRecordsCount,
          )));
    }
    for (final controller in [start, end, rent, deposit, billing, notes]) {
      controller.dispose();
    }
  }

  Future<void> _end(BuildContext context, Tenancy item) async {
    final reason = TextEditingController();
    var propertyStatus = PropertyStatus.available;
    final confirm = await showDialog<bool>(
        context: context,
        builder: (dialog) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                    title: const Text('End tenancy'),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      DropdownButtonFormField(
                          initialValue: propertyStatus,
                          decoration: const InputDecoration(
                              labelText: 'Property status'),
                          items: const [
                            DropdownMenuItem(
                                value: PropertyStatus.available,
                                child: Text('Available')),
                            DropdownMenuItem(
                                value: PropertyStatus.inactive,
                                child: Text('Inactive'))
                          ],
                          onChanged: (value) =>
                              setDialogState(() => propertyStatus = value!)),
                      const SizedBox(height: 10),
                      TextField(
                          controller: reason,
                          decoration: const InputDecoration(
                              labelText: 'Reason (optional)'))
                    ]),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(dialog, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(dialog, true),
                          child: const Text('End'))
                    ])));
    if (confirm == true && context.mounted) {
      context.read<OwnerTenanciesBloc>().add(OwnerTenancyEnded(item.id,
          endDate: DateTime.now(),
          propertyStatus: propertyStatus,
          reason: reason.text));
    }
    reason.dispose();
  }
}

class NewRenterTenancyFormResult {
  const NewRenterTenancyFormResult({
    required this.property,
    required this.renterName,
    required this.renterEmail,
    required this.renterPhone,
    required this.startDate,
    this.endDate,
    required this.agreedRent,
    required this.deposit,
    this.billingDay,
    required this.notes,
  });

  final RentalProperty property;
  final String renterName;
  final String renterEmail;
  final String renterPhone;
  final DateTime startDate;
  final DateTime? endDate;
  final double agreedRent;
  final double deposit;
  final int? billingDay;
  final String notes;
}

class NewRenterTenancyScreen extends StatefulWidget {
  const NewRenterTenancyScreen({super.key, required this.properties});

  final List<RentalProperty> properties;

  @override
  State<NewRenterTenancyScreen> createState() => _NewRenterTenancyScreenState();
}

class _NewRenterTenancyScreenState extends State<NewRenterTenancyScreen> {
  final formKey = GlobalKey<FormState>();
  late RentalProperty property;
  late final TextEditingController name,
      email,
      phone,
      start,
      end,
      rent,
      deposit,
      billing,
      notes;

  @override
  void initState() {
    super.initState();
    property = widget.properties.first;
    name = TextEditingController();
    email = TextEditingController();
    phone = TextEditingController();
    start = TextEditingController(text: _apiDate(DateTime.now()));
    end = TextEditingController();
    rent = TextEditingController(text: property.monthlyRent.toStringAsFixed(2));
    deposit = TextEditingController(text: '0.00');
    billing = TextEditingController();
    notes = TextEditingController();
  }

  @override
  void dispose() {
    for (final controller in [
      name,
      email,
      phone,
      start,
      end,
      rent,
      deposit,
      billing,
      notes
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Assign new renter')),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              DropdownButtonFormField<RentalProperty>(
                initialValue: property,
                decoration: const InputDecoration(labelText: 'Property'),
                items: widget.properties
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item.title)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    property = value;
                    rent.text = value.monthlyRent.toStringAsFixed(2);
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Renter name'),
                validator: _required,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Renter email'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Renter phone'),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: start,
                  decoration:
                      const InputDecoration(labelText: 'Start (YYYY-MM-DD)'),
                  validator: _dateValidator,
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: TextFormField(
                  controller: end,
                  decoration:
                      const InputDecoration(labelText: 'End (optional)'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? null
                      : _dateValidator(value),
                )),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: rent,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Agreed rent'),
                  validator: _moneyValidator,
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: TextFormField(
                  controller: deposit,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Deposit'),
                  validator: _moneyValidator,
                )),
              ]),
              const SizedBox(height: 10),
              TextFormField(
                controller: billing,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Billing day (optional)'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final day = int.tryParse(value);
                  return day == null || day < 1 || day > 31
                      ? 'Use a day from 1 to 31'
                      : null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                  onPressed: _save,
                  child: const Text('Create renter and tenancy')),
            ],
          ),
        ),
      );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  String? _dateValidator(String? value) =>
      DateTime.tryParse(value ?? '') == null
          ? 'Use a valid YYYY-MM-DD date'
          : null;

  String? _moneyValidator(String? value) {
    final amount = double.tryParse(value ?? '');
    return amount == null || amount < 0 ? 'Enter zero or more' : null;
  }

  void _save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (email.text.trim().isEmpty && phone.text.trim().isEmpty) {
      showActionMessage(context, 'Enter an email address or phone number.');
      return;
    }
    final startDate = DateTime.parse(start.text.trim());
    final endDate =
        end.text.trim().isEmpty ? null : DateTime.parse(end.text.trim());
    if (endDate != null && endDate.isBefore(startDate)) {
      showActionMessage(context, 'End date cannot be before the start date.');
      return;
    }
    Navigator.pop(
        context,
        NewRenterTenancyFormResult(
          property: property,
          renterName: name.text.trim(),
          renterEmail: email.text.trim(),
          renterPhone: phone.text.trim(),
          startDate: startDate,
          endDate: endDate,
          agreedRent: double.parse(rent.text),
          deposit: double.parse(deposit.text),
          billingDay: int.tryParse(billing.text),
          notes: notes.text.trim(),
        ));
  }
}

class OwnerMonthlyRecordsView extends StatelessWidget {
  const OwnerMonthlyRecordsView({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<OwnerMonthlyRecordsBloc, OwnerMonthlyRecordsState>(
          listener: (context, state) {
        if (state case OwnerMonthlyRecordsLoaded(message: final message)) {
          showActionMessage(context, message);
        }
        if (state case OwnerMonthlyRecordsError(message: final message)) {
          showActionMessage(context, message);
        }
      }, builder: (context, state) {
        if (state is OwnerMonthlyRecordsInitial ||
            state is OwnerMonthlyRecordsLoading) {
          return const FeatureLoading(label: 'Loading monthly records…');
        }
        if (state is OwnerMonthlyRecordsError) {
          return FeatureErrorView(
              message: state.message,
              onRetry: () => context
                  .read<OwnerMonthlyRecordsBloc>()
                  .add(const OwnerMonthlyRecordsRequested()));
        }
        final items = state is OwnerMonthlyRecordsLoaded
            ? state.records
            : <MonthlyRecord>[];
        if (items.isEmpty) {
          return const FeatureEmpty(
              title: 'No monthly records',
              message: 'Renter monthly submissions will appear here.',
              icon: Icons.receipt_long_outlined);
        }
        return RefreshIndicator(
            onRefresh: () async => context
                .read<OwnerMonthlyRecordsBloc>()
                .add(const OwnerMonthlyRecordsRequested()),
            child: ListView(
                padding: const EdgeInsets.all(16),
                children: items
                    .map((item) => MonthlyRecordCard(
                        record: item, onTap: () => _review(context, item)))
                    .toList()));
      });
  Future<void> _review(BuildContext context, MonthlyRecord record) async {
    final decision = await Navigator.push<MonthlyReviewDecision>(
        context,
        MaterialPageRoute(
            builder: (_) => MonthlyRecordDetailScreen(
                recordId: record.id, canReview: true)));
    if (decision != null && context.mounted) {
      switch (decision.action) {
        case MonthlyReviewAction.approve:
          context.read<OwnerMonthlyRecordsBloc>().add(
              OwnerMonthlyRecordReviewed(
                  record.id, MonthlyRecordStatus.approved));
        case MonthlyReviewAction.reject:
          context.read<OwnerMonthlyRecordsBloc>().add(
              OwnerMonthlyRecordReviewed(
                  record.id, MonthlyRecordStatus.rejected,
                  comment: decision.reason));
        case MonthlyReviewAction.reopen:
          context
              .read<OwnerMonthlyRecordsBloc>()
              .add(OwnerMonthlyRecordReopened(record.id, decision.reason));
      }
    }
  }
}

class OwnerMaintenanceView extends StatelessWidget {
  const OwnerMaintenanceView({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<OwnerMaintenanceBloc, OwnerMaintenanceState>(
          listener: (context, state) {
        if (state case OwnerMaintenanceLoaded(message: final message)) {
          showActionMessage(context, message);
        }
        if (state case OwnerMaintenanceError(message: final message)) {
          showActionMessage(context, message);
        }
      }, builder: (context, state) {
        if (state is OwnerMaintenanceInitial ||
            state is OwnerMaintenanceLoading) {
          return const FeatureLoading(label: 'Loading maintenance…');
        }
        if (state is OwnerMaintenanceError) {
          return FeatureErrorView(
              message: state.message,
              onRetry: () => context
                  .read<OwnerMaintenanceBloc>()
                  .add(const OwnerMaintenanceRequested()));
        }
        final items = state is OwnerMaintenanceLoaded
            ? state.requests
            : <MaintenanceRequest>[];
        if (items.isEmpty) {
          return const FeatureEmpty(
              title: 'No maintenance requests',
              message: 'Requests from your renters will appear here.',
              icon: Icons.build_outlined);
        }
        return RefreshIndicator(
            onRefresh: () async => context
                .read<OwnerMaintenanceBloc>()
                .add(const OwnerMaintenanceRequested()),
            child: ListView(
                padding: const EdgeInsets.all(16),
                children: items
                    .map((item) => Card(
                        child: InkWell(
                            onTap: () => _details(context, item),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Expanded(
                                            child: Text(item.title,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        EntityStatusBadge(status: item.status)
                                      ]),
                                      Text(
                                          '${item.propertyTitle} · ${item.priority.displayLabel} priority'),
                                      Text(item.description),
                                      if (item.attachments.isNotEmpty)
                                        Text(
                                            '${item.attachments.length} attachment(s)'),
                                      if (item.timeline.isNotEmpty)
                                        Text(
                                            '${item.timeline.length} timeline event(s)'),
                                      if (item.allowedTransitions.isNotEmpty)
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Wrap(
                                                spacing: 8,
                                                children: item.allowedTransitions
                                                    .map((status) => FilledButton.tonal(
                                                        onPressed: () => context
                                                            .read<
                                                                OwnerMaintenanceBloc>()
                                                            .add(
                                                                OwnerMaintenanceStatusChanged(
                                                                    item.id,
                                                                    status)),
                                                        child: Text(
                                                            status.displayLabel)))
                                                    .toList()))
                                    ])))))
                    .toList()));
      });

  Future<void> _details(
      BuildContext context, MaintenanceRequest request) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => MaintenanceDetailScreen(
          requestId: request.id,
          isOwner: true,
        ),
      ),
    );
    if (context.mounted) {
      context
          .read<OwnerMaintenanceBloc>()
          .add(const OwnerMaintenanceRequested());
    }
  }
}

String _apiDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

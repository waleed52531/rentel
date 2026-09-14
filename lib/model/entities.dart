import 'package:flutter/material.dart';

enum AppLanguage { english, urdu }

enum AppRole { renter, owner, unknown }

enum AuthMethod { phoneOtp, emailPassword }

enum PropertyStatus { available, occupied, inactive, unknown }

enum PublicationStatus { draft, published, unknown }

enum PropertyType { house, office, guestHouse, unknown }

enum RentalMode { whole, byFloor, unknown }

enum ApplicationStatus {
  pending,
  reviewed,
  accepted,
  rejected,
  withdrawn,
  unknown
}

enum TenancyStatus { active, ended, cancelled, unknown }

enum MaintenanceStatus { pending, inProgress, completed, cancelled, unknown }

enum MaintenancePriority { low, medium, high, urgent, unknown }

enum MonthlyRecordStatus { draft, pending, approved, rejected, unknown }

enum PaymentCategory {
  rent,
  electricity,
  gas,
  water,
  internet,
  maintenance,
  other,
  unknown
}

T _enumFromWire<T extends Enum>(
    String raw, List<T> values, Map<String, T> aliases, T unknown) {
  final normalized = raw.trim().toLowerCase();
  return aliases[normalized] ??
      values
          .where((value) => value.name.toLowerCase() == normalized)
          .firstOrNull ??
      unknown;
}

String enumWireValue(Enum value) => switch (value) {
      PropertyType.guestHouse => 'guest_house',
      RentalMode.byFloor => 'by_floor',
      MaintenanceStatus.inProgress => 'in_progress',
      _ => value.name,
    };

extension EnumLabel on Enum {
  String get displayLabel => enumWireValue(this)
      .split('_')
      .map((part) =>
          part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

double jsonMoney(Object? value) =>
    double.tryParse(value?.toString() ?? '') ?? 0;
int jsonInt(Object? value) => int.tryParse(value?.toString() ?? '') ?? 0;
DateTime? jsonDate(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());
Map<String, dynamic> jsonMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};
List<Map<String, dynamic>> jsonMapList(Object? value) => value is List
    ? value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false)
    : const [];

class AppUser {
  const AppUser(
      {required this.id,
      required this.name,
      required this.email,
      required this.role,
      required this.rawRole,
      this.phone = '',
      this.status = '',
      this.profileImageUrl});
  final String id;
  final String name;
  final String email;
  final String phone;
  final AppRole role;
  final String rawRole;
  final String status;
  final String? profileImageUrl;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final raw = json['role']?.toString() ?? '';
    return AppUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: _enumFromWire(raw, AppRole.values, const {}, AppRole.unknown),
      rawRole: raw,
      status: json['status']?.toString() ?? '',
      profileImageUrl: json['profile_image_url']?.toString(),
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': rawRole,
        'status': status,
        'profile_image_url': profileImageUrl
      };
}

class PropertyMedia {
  const PropertyMedia(
      {required this.id,
      required this.url,
      required this.isVideo,
      this.isPrimary = false,
      this.mimeType = '',
      this.sizeBytes = 0,
      this.sortOrder = 0});
  final String id;
  final String url;
  final bool isVideo;
  final bool isPrimary;
  final String mimeType;
  final int sizeBytes;
  final int sortOrder;

  factory PropertyMedia.image(Map<String, dynamic> json) => PropertyMedia(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      isVideo: false,
      isPrimary: json['is_primary'] == true,
      sortOrder: jsonInt(json['sort_order']));
  factory PropertyMedia.video(Map<String, dynamic> json) => PropertyMedia(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      isVideo: true,
      mimeType: json['mime_type']?.toString() ?? '',
      sizeBytes: jsonInt(json['size_bytes']),
      sortOrder: jsonInt(json['sort_order']));
}

class RentalProperty {
  const RentalProperty({
    required this.id,
    required this.title,
    required this.type,
    required this.rawType,
    required this.rentalMode,
    required this.rawRentalMode,
    required this.monthlyRent,
    required this.area,
    required this.city,
    required this.address,
    required this.description,
    required this.status,
    required this.rawStatus,
    required this.publicationStatus,
    required this.rawPublicationStatus,
    this.isRentable = true,
    this.houseId,
    this.unitLabel = '',
    this.floorNumber,
    this.currency = 'PKR',
    this.isPubliclyVisible = false,
    this.publishedAt,
    this.contactName = '',
    this.contactPhone = '',
    this.contactEmail = '',
    this.images = const [],
    this.videos = const [],
    this.floors = const [],
    this.applicationsCount = 0,
    this.imagesCount = 0,
    this.videosCount = 0,
  });
  final String id;
  final String title;
  final PropertyType type;
  final String rawType;
  final RentalMode rentalMode;
  final String rawRentalMode;
  final bool isRentable;
  final String? houseId;
  final String unitLabel;
  final int? floorNumber;
  final double monthlyRent;
  final String currency;
  final String area;
  final String city;
  final String address;
  final String description;
  final PropertyStatus status;
  final String rawStatus;
  final PublicationStatus publicationStatus;
  final String rawPublicationStatus;
  final bool isPubliclyVisible;
  final DateTime? publishedAt;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final List<PropertyMedia> images;
  final List<PropertyMedia> videos;
  final List<RentalProperty> floors;
  final int applicationsCount;
  final int imagesCount;
  final int videosCount;
  List<String> get mediaUrls =>
      [...images.map((item) => item.url), ...videos.map((item) => item.url)];

  factory RentalProperty.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString() ?? '';
    final rawMode = json['rental_mode']?.toString() ?? 'whole';
    final rawStatus = json['status']?.toString() ?? 'available';
    final rawPublication = json['publication_status']?.toString() ??
        (json['published_at'] == null ? 'draft' : 'published');
    final contact = jsonMap(json['contact']);
    final imageJson = jsonMapList(json['images']);
    final primary = jsonMap(json['primary_image']);
    final images = imageJson.map(PropertyMedia.image).toList();
    if (primary.isNotEmpty &&
        !images.any((item) => item.id == primary['id']?.toString())) {
      images.insert(0, PropertyMedia.image(primary));
    }
    return RentalProperty(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: _enumFromWire(rawType, PropertyType.values,
          const {'guest_house': PropertyType.guestHouse}, PropertyType.unknown),
      rawType: rawType,
      rentalMode: _enumFromWire(rawMode, RentalMode.values,
          const {'by_floor': RentalMode.byFloor}, RentalMode.unknown),
      rawRentalMode: rawMode,
      isRentable: json['is_rentable'] != false,
      houseId: json['house_id']?.toString(),
      unitLabel: json['unit_label']?.toString() ?? '',
      floorNumber:
          json['floor_number'] == null ? null : jsonInt(json['floor_number']),
      monthlyRent: jsonMoney(json['rent_amount']),
      currency: json['currency']?.toString() ?? 'PKR',
      area: json['area']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: _enumFromWire(
          rawStatus, PropertyStatus.values, const {}, PropertyStatus.unknown),
      rawStatus: rawStatus,
      publicationStatus: _enumFromWire(rawPublication, PublicationStatus.values,
          const {}, PublicationStatus.unknown),
      rawPublicationStatus: rawPublication,
      isPubliclyVisible:
          json['is_publicly_visible'] == true || rawPublication == 'published',
      publishedAt: jsonDate(json['published_at']),
      contactName: contact['name']?.toString() ?? '',
      contactPhone: contact['phone']?.toString() ?? '',
      contactEmail: contact['email']?.toString() ?? '',
      images: images,
      videos: jsonMapList(json['videos'])
          .map(PropertyMedia.video)
          .toList(growable: false),
      floors: jsonMapList(json['floors'])
          .map(RentalProperty.fromJson)
          .toList(growable: false),
      applicationsCount: jsonInt(json['applications_count']),
      imagesCount: jsonInt(json['images_count']),
      videosCount: jsonInt(json['videos_count']),
    );
  }

  Map<String, String> toRequestFields() => {
        'type': enumWireValue(type),
        'rental_mode': enumWireValue(rentalMode),
        'title': title,
        'rent_amount': monthlyRent.toStringAsFixed(2),
        'area': area,
        'city': city,
        'address': address,
        'contact_name': contactName,
        'contact_phone': contactPhone,
        'contact_email': contactEmail,
        'description': description,
        'status': enumWireValue(status),
        'publication_status': enumWireValue(publicationStatus),
      };

  RentalProperty copyWith({
    String? title,
    PropertyType? type,
    RentalMode? rentalMode,
    double? monthlyRent,
    String? area,
    String? city,
    String? address,
    String? description,
    PropertyStatus? status,
    PublicationStatus? publicationStatus,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    List<PropertyMedia>? images,
    List<PropertyMedia>? videos,
  }) =>
      RentalProperty(
        id: id,
        title: title ?? this.title,
        type: type ?? this.type,
        rawType: enumWireValue(type ?? this.type),
        rentalMode: rentalMode ?? this.rentalMode,
        rawRentalMode: enumWireValue(rentalMode ?? this.rentalMode),
        monthlyRent: monthlyRent ?? this.monthlyRent,
        area: area ?? this.area,
        city: city ?? this.city,
        address: address ?? this.address,
        description: description ?? this.description,
        status: status ?? this.status,
        rawStatus: enumWireValue(status ?? this.status),
        publicationStatus: publicationStatus ?? this.publicationStatus,
        rawPublicationStatus:
            enumWireValue(publicationStatus ?? this.publicationStatus),
        isRentable: isRentable,
        houseId: houseId,
        unitLabel: unitLabel,
        floorNumber: floorNumber,
        currency: currency,
        isPubliclyVisible: isPubliclyVisible,
        publishedAt: publishedAt,
        contactName: contactName ?? this.contactName,
        contactPhone: contactPhone ?? this.contactPhone,
        contactEmail: contactEmail ?? this.contactEmail,
        images: images ?? this.images,
        videos: videos ?? this.videos,
        floors: floors,
        applicationsCount: applicationsCount,
        imagesCount: imagesCount,
        videosCount: videosCount,
      );
}

class RentalApplication {
  const RentalApplication(
      {required this.id,
      required this.propertyId,
      required this.message,
      required this.status,
      required this.rawStatus,
      required this.createdAt,
      this.contactPhone = '',
      this.ownerNote = '',
      this.respondedAt,
      this.property,
      this.renter});
  final String id;
  final String propertyId;
  final String message;
  final String contactPhone;
  final ApplicationStatus status;
  final String rawStatus;
  final String ownerNote;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final RentalProperty? property;
  final AppUser? renter;
  String get propertyTitle => property?.title ?? 'Property';
  String get renterId => renter?.id ?? '';
  String get renterName => renter?.name ?? 'Renter';

  factory RentalApplication.fromJson(Map<String, dynamic> json) {
    final raw = json['status']?.toString() ?? '';
    final propertyJson = jsonMap(json['property']);
    final renterJson = jsonMap(json['renter']);
    return RentalApplication(
        id: json['id']?.toString() ?? '',
        propertyId: json['property_id']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        contactPhone: json['contact_phone']?.toString() ?? '',
        status: _enumFromWire(
            raw, ApplicationStatus.values, const {}, ApplicationStatus.unknown),
        rawStatus: raw,
        ownerNote: json['owner_note']?.toString() ?? '',
        createdAt: jsonDate(json['submitted_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        respondedAt: jsonDate(json['responded_at']),
        property:
            propertyJson.isEmpty ? null : RentalProperty.fromJson(propertyJson),
        renter: renterJson.isEmpty ? null : AppUser.fromJson(renterJson));
  }
}

class Tenancy {
  const Tenancy(
      {required this.id,
      required this.status,
      required this.rawStatus,
      required this.startDate,
      required this.monthlyRent,
      this.endDate,
      this.deposit = 0,
      this.billingDay,
      this.notes = '',
      this.endedAt,
      this.endReason = '',
      this.property,
      this.renter,
      this.monthlyRecordsCount = 0});
  final String id;
  final TenancyStatus status;
  final String rawStatus;
  final DateTime startDate;
  final DateTime? endDate;
  final double monthlyRent;
  final double deposit;
  final int? billingDay;
  final String notes;
  final DateTime? endedAt;
  final String endReason;
  final RentalProperty? property;
  final AppUser? renter;
  final int monthlyRecordsCount;
  String get propertyId => property?.id ?? '';
  String get propertyTitle => property?.title ?? 'Property';
  String get renterId => renter?.id ?? '';
  String get renterName => renter?.name ?? 'Renter';

  factory Tenancy.fromJson(Map<String, dynamic> json) {
    final raw = json['status']?.toString() ?? '';
    final p = jsonMap(json['property']);
    final r = jsonMap(json['renter']);
    return Tenancy(
        id: json['id']?.toString() ?? '',
        status: _enumFromWire(
            raw, TenancyStatus.values, const {}, TenancyStatus.unknown),
        rawStatus: raw,
        startDate: jsonDate(json['start_date']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        endDate: jsonDate(json['end_date']),
        monthlyRent: jsonMoney(json['agreed_rent']),
        deposit: jsonMoney(json['deposit']),
        billingDay:
            json['billing_day'] == null ? null : jsonInt(json['billing_day']),
        notes: json['notes']?.toString() ?? '',
        endedAt: jsonDate(json['ended_at']),
        endReason: json['end_reason']?.toString() ?? '',
        property: p.isEmpty ? null : RentalProperty.fromJson(p),
        renter: r.isEmpty ? null : AppUser.fromJson(r),
        monthlyRecordsCount: jsonInt(json['monthly_records_count']));
  }
}

class MonthlyProof {
  const MonthlyProof(
      {required this.id,
      required this.category,
      required this.rawCategory,
      required this.originalName,
      required this.downloadUrl,
      this.mimeType = '',
      this.sizeBytes = 0,
      this.isImage = false});
  final String id;
  final PaymentCategory category;
  final String rawCategory;
  final String originalName;
  final String mimeType;
  final int sizeBytes;
  final bool isImage;
  final String downloadUrl;
  factory MonthlyProof.fromJson(Map<String, dynamic> json) {
    final raw = json['category']?.toString() ?? '';
    return MonthlyProof(
        id: json['id']?.toString() ?? '',
        category: _enumFromWire(
            raw, PaymentCategory.values, const {}, PaymentCategory.unknown),
        rawCategory: raw,
        originalName: json['original_name']?.toString() ?? '',
        mimeType: json['mime_type']?.toString() ?? '',
        sizeBytes: jsonInt(json['size_bytes']),
        isImage: json['is_image'] == true,
        downloadUrl: json['download_url']?.toString() ?? '');
  }
}

class MonthlyRecord {
  const MonthlyRecord(
      {required this.id,
      required this.tenancyId,
      required this.month,
      required this.amounts,
      required this.notes,
      required this.status,
      required this.rawStatus,
      this.currency = 'PKR',
      this.totalAmount = 0,
      this.isFrozen = false,
      this.isEditableByRenter = false,
      this.submittedAt,
      this.approvedAt,
      this.rejectedAt,
      this.rejectionReason = '',
      this.frozenAt,
      this.reopenedAt,
      this.reopenReason = '',
      this.tenancy,
      this.proofs = const [],
      this.proofsCount = 0});
  final String id;
  final String tenancyId;
  final String month;
  final Map<PaymentCategory, double> amounts;
  final double totalAmount;
  final String currency;
  final String notes;
  final MonthlyRecordStatus status;
  final String rawStatus;
  final bool isFrozen;
  final bool isEditableByRenter;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String rejectionReason;
  final DateTime? frozenAt;
  final DateTime? reopenedAt;
  final String reopenReason;
  final Tenancy? tenancy;
  final List<MonthlyProof> proofs;
  final int proofsCount;
  String get propertyTitle => tenancy?.propertyTitle ?? 'Property';
  double get baseRent => amounts[PaymentCategory.rent] ?? 0;
  double get finalPayable => totalAmount;
  int get proofCount => proofs.isEmpty ? proofsCount : proofs.length;

  factory MonthlyRecord.fromJson(Map<String, dynamic> json) {
    final raw = json['status']?.toString() ?? '';
    final amountJson = jsonMap(json['amounts']);
    final amountMap = <PaymentCategory, double>{};
    for (final entry in amountJson.entries) {
      final category = _enumFromWire(entry.key, PaymentCategory.values,
          const <String, PaymentCategory>{}, PaymentCategory.unknown);
      if (category != PaymentCategory.unknown) {
        amountMap[category] = jsonMoney(entry.value);
      }
    }
    final t = jsonMap(json['tenancy']);
    return MonthlyRecord(
        id: json['id']?.toString() ?? '',
        tenancyId: json['tenancy_id']?.toString() ?? '',
        month: json['period_month']?.toString() ?? '',
        amounts: amountMap,
        totalAmount: jsonMoney(json['total_amount']),
        currency: json['currency']?.toString() ?? 'PKR',
        notes: json['notes']?.toString() ?? '',
        status: _enumFromWire(raw, MonthlyRecordStatus.values, const {},
            MonthlyRecordStatus.unknown),
        rawStatus: raw,
        isFrozen: json['is_frozen'] == true,
        isEditableByRenter: json['is_editable_by_renter'] == true,
        submittedAt: jsonDate(json['submitted_at']),
        approvedAt: jsonDate(json['approved_at']),
        rejectedAt: jsonDate(json['rejected_at']),
        rejectionReason: json['rejection_reason']?.toString() ?? '',
        frozenAt: jsonDate(json['frozen_at']),
        reopenedAt: jsonDate(json['reopened_at']),
        reopenReason: json['reopen_reason']?.toString() ?? '',
        tenancy: t.isEmpty ? null : Tenancy.fromJson(t),
        proofs: jsonMapList(json['proofs'])
            .map(MonthlyProof.fromJson)
            .toList(growable: false),
        proofsCount: jsonInt(json['proofs_count']));
  }

  Map<String, String> toAmountFields() => {
        'notes': notes,
        for (final category in PaymentCategory.values
            .where((item) => item != PaymentCategory.unknown))
          '${enumWireValue(category)}_amount':
              (amounts[category] ?? 0).toStringAsFixed(2)
      };
}

class MaintenanceAttachment {
  const MaintenanceAttachment(
      {required this.id,
      required this.originalName,
      required this.mimeType,
      required this.downloadUrl});
  final String id;
  final String originalName;
  final String mimeType;
  final String downloadUrl;
  factory MaintenanceAttachment.fromJson(Map<String, dynamic> json) =>
      MaintenanceAttachment(
          id: json['id']?.toString() ?? '',
          originalName: json['original_name']?.toString() ?? '',
          mimeType: json['mime_type']?.toString() ?? '',
          downloadUrl: json['download_url']?.toString() ?? '');
}

class MaintenanceTimelineEntry {
  const MaintenanceTimelineEntry(
      {required this.id,
      required this.toStatus,
      required this.rawToStatus,
      required this.changedAt,
      this.fromStatus,
      this.comment = '',
      this.changedBy = ''});
  final String id;
  final MaintenanceStatus? fromStatus;
  final MaintenanceStatus toStatus;
  final String rawToStatus;
  final String comment;
  final String changedBy;
  final DateTime changedAt;
  factory MaintenanceTimelineEntry.fromJson(Map<String, dynamic> json) {
    final raw = json['to_status']?.toString() ?? '';
    final from = json['from_status']?.toString();
    return MaintenanceTimelineEntry(
        id: json['id']?.toString() ?? '',
        fromStatus: from == null
            ? null
            : _enumFromWire(
                from,
                MaintenanceStatus.values,
                const {'in_progress': MaintenanceStatus.inProgress},
                MaintenanceStatus.unknown),
        toStatus: _enumFromWire(
            raw,
            MaintenanceStatus.values,
            const {'in_progress': MaintenanceStatus.inProgress},
            MaintenanceStatus.unknown),
        rawToStatus: raw,
        comment: json['comment']?.toString() ?? '',
        changedBy: json['changed_by']?.toString() ?? '',
        changedAt: jsonDate(json['changed_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0));
  }
}

class MaintenanceRequest {
  const MaintenanceRequest(
      {required this.id,
      required this.tenancyId,
      required this.title,
      required this.description,
      required this.priority,
      required this.rawPriority,
      required this.status,
      required this.rawStatus,
      required this.createdAt,
      this.isOpen = false,
      this.allowedTransitions = const [],
      this.completedAt,
      this.tenancy,
      this.attachments = const [],
      this.timeline = const []});
  final String id;
  final String tenancyId;
  final String title;
  final String description;
  final MaintenancePriority priority;
  final String rawPriority;
  final MaintenanceStatus status;
  final String rawStatus;
  final bool isOpen;
  final List<MaintenanceStatus> allowedTransitions;
  final DateTime? completedAt;
  final DateTime createdAt;
  final Tenancy? tenancy;
  final List<MaintenanceAttachment> attachments;
  final List<MaintenanceTimelineEntry> timeline;
  String get propertyTitle => tenancy?.propertyTitle ?? 'Property';
  String get renterId => tenancy?.renterId ?? '';

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    final rawPriority = json['priority']?.toString() ?? '';
    final rawStatus = json['status']?.toString() ?? '';
    final t = jsonMap(json['tenancy']);
    return MaintenanceRequest(
        id: json['id']?.toString() ?? '',
        tenancyId: json['tenancy_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        priority: _enumFromWire(rawPriority, MaintenancePriority.values,
            const {}, MaintenancePriority.unknown),
        rawPriority: rawPriority,
        status: _enumFromWire(
            rawStatus,
            MaintenanceStatus.values,
            const {'in_progress': MaintenanceStatus.inProgress},
            MaintenanceStatus.unknown),
        rawStatus: rawStatus,
        isOpen: json['is_open'] == true,
        allowedTransitions: (json['allowed_transitions'] is List
                ? json['allowed_transitions'] as List
                : const [])
            .map((value) => _enumFromWire(
                value.toString(),
                MaintenanceStatus.values,
                const {'in_progress': MaintenanceStatus.inProgress},
                MaintenanceStatus.unknown))
            .where((value) => value != MaintenanceStatus.unknown)
            .toList(growable: false),
        completedAt: jsonDate(json['completed_at']),
        createdAt: jsonDate(json['created_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        tenancy: t.isEmpty ? null : Tenancy.fromJson(t),
        attachments: jsonMapList(json['attachments'])
            .map(MaintenanceAttachment.fromJson)
            .toList(growable: false),
        timeline: jsonMapList(json['timeline'])
            .map(MaintenanceTimelineEntry.fromJson)
            .toList(growable: false));
  }
}

class AppNotification {
  const AppNotification(
      {required this.id,
      required this.type,
      required this.title,
      required this.body,
      required this.createdAt,
      required this.isRead,
      this.data = const {},
      this.actionUrl,
      this.readAt});
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? actionUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
          id: json['id']?.toString() ?? '',
          type: json['type']?.toString() ?? '',
          title: json['title']?.toString() ?? '',
          body: json['body']?.toString() ?? '',
          data: jsonMap(json['data']),
          actionUrl: json['action_url']?.toString(),
          isRead: json['is_read'] == true,
          readAt: jsonDate(json['read_at']),
          createdAt: jsonDate(json['created_at']) ??
              DateTime.fromMillisecondsSinceEpoch(0));
}

class PageInfo {
  const PageInfo(
      {required this.currentPage,
      required this.lastPage,
      required this.perPage,
      required this.total});
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  bool get hasMore => currentPage < lastPage;
  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
      currentPage: jsonInt(json['current_page']),
      lastPage: jsonInt(json['last_page']),
      perPage: jsonInt(json['per_page']),
      total: jsonInt(json['total']));
}

class PagedResult<T> {
  const PagedResult(
      {required this.items, required this.pageInfo, this.extraMeta = const {}});
  final List<T> items;
  final PageInfo pageInfo;
  final Map<String, dynamic> extraMeta;
}

extension MonthlyRecordStatusView on MonthlyRecordStatus {
  String get label => displayLabel;
  Color get color => switch (this) {
        MonthlyRecordStatus.pending => Colors.orange,
        MonthlyRecordStatus.approved => Colors.green,
        MonthlyRecordStatus.rejected => Colors.red,
        _ => Colors.grey
      };
  bool get isLocked =>
      this == MonthlyRecordStatus.pending ||
      this == MonthlyRecordStatus.approved;
  bool get canRenterEdit =>
      this == MonthlyRecordStatus.draft || this == MonthlyRecordStatus.rejected;
}

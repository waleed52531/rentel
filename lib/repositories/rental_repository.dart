import '../core/api/app_api_client.dart';
import '../core/errors/app_exception.dart';
import '../core/storage/secure_session_store.dart';
import '../models/entities.dart';

abstract interface class RentalRepository {
  Future<List<RentalProperty>> getOwnerProperties();
  Future<RentalProperty> getOwnerProperty(String id);
  Future<RentalProperty> saveProperty(RentalProperty property,
      {List<String> imagePaths, List<String> videoPaths});
  Future<List<RentalProperty>> getPublishedListings(
      {String area, PropertyType? type, double? minRent, double? maxRent});
  Future<RentalProperty> getListing(String id);

  Future<List<RentalApplication>> getApplications();
  Future<RentalApplication> apply(String propertyId, String message,
      {String contactPhone});
  Future<void> updateApplicationStatus(
      String applicationId, ApplicationStatus status,
      {String ownerNote});

  Future<List<Tenancy>> getTenancies();
  Future<Tenancy> getTenancy(String id);
  Future<Tenancy> createTenancyFromApplication(
      String applicationId, DateTime startDate);
  Future<TenancyCreationResponse> createTenancyWithNewRenter({
    required String propertyId,
    required String renterName,
    String renterEmail,
    String renterPhone,
    required DateTime startDate,
    DateTime? endDate,
    required double agreedRent,
    double deposit,
    int? billingDay,
    String notes,
  });
  Future<Tenancy> updateTenancy(Tenancy tenancy);
  Future<void> endTenancy(String tenancyId,
      {required DateTime endDate,
      required PropertyStatus propertyStatus,
      String reason});

  Future<List<MonthlyRecord>> getMonthlyRecords();
  Future<MonthlyRecord> getMonthlyRecord(String id);
  Future<MonthlyRecord> saveMonthlyRecord(MonthlyRecord record,
      {required bool submit, Map<PaymentCategory, List<String>> proofPaths});
  Future<void> approveMonthlyRecord(String id);
  Future<void> rejectMonthlyRecord(String id, String reason);
  Future<void> reopenMonthlyRecord(String id, String reason);

  Future<List<MaintenanceRequest>> getMaintenanceRequests();
  Future<MaintenanceRequest> getMaintenanceRequest(String id);
  Future<MaintenanceRequest> createMaintenanceRequest(
      {required String tenancyId,
      required String title,
      required String description,
      required MaintenancePriority priority,
      List<String> attachmentPaths});
  Future<void> updateMaintenanceStatus(String id, MaintenanceStatus status,
      {String comment});
  Future<void> commentMaintenance(String id, String comment);

  Future<List<AppNotification>> getNotifications({bool unread});
  Future<void> markNotificationsRead({List<String> ids});
}

class ApiRentalRepository implements RentalRepository {
  const ApiRentalRepository(
      {required this.apiClient, required this.sessionStore});
  final AppApiClient apiClient;
  final SecureSessionStore sessionStore;

  Future<String> _token() async {
    final value = await sessionStore.readToken();
    if (value == null || value.isEmpty) {
      throw const AppException(
          'Your session has expired. Please sign in again.',
          type: AppErrorType.unauthorized);
    }
    return value;
  }

  Future<List<T>> _allPages<T>(
      Future<PagedResult<T>> Function(int page) fetch) async {
    final result = <T>[];
    var page = 1;
    var hasMore = true;
    while (hasMore) {
      final response = await fetch(page);
      result.addAll(response.items);
      hasMore = response.pageInfo.hasMore;
      page++;
    }
    return result;
  }

  @override
  Future<List<RentalProperty>> getOwnerProperties() async {
    final token = await _token();
    return _allPages((page) => apiClient.properties(token, page: page));
  }

  @override
  Future<RentalProperty> getOwnerProperty(String id) async =>
      apiClient.property(await _token(), id);
  @override
  Future<RentalProperty> saveProperty(RentalProperty property,
          {List<String> imagePaths = const [],
          List<String> videoPaths = const []}) async =>
      apiClient.saveProperty(await _token(), property,
          imagePaths: imagePaths, videoPaths: videoPaths);
  @override
  Future<List<RentalProperty>> getPublishedListings(
      {String area = '',
      PropertyType? type,
      double? minRent,
      double? maxRent}) async {
    final token = await _token();
    return _allPages((page) => apiClient.listings(
        token: token,
        area: area,
        type: type,
        minRent: minRent,
        maxRent: maxRent,
        page: page));
  }

  @override
  Future<RentalProperty> getListing(String id) async =>
      apiClient.listing(id, token: await _token());

  @override
  Future<List<RentalApplication>> getApplications() async {
    final token = await _token();
    return _allPages((page) => apiClient.applications(token, page: page));
  }

  @override
  Future<RentalApplication> apply(String propertyId, String message,
          {String contactPhone = ''}) async =>
      apiClient.apply(await _token(), propertyId,
          message: message, contactPhone: contactPhone);
  @override
  Future<void> updateApplicationStatus(
      String applicationId, ApplicationStatus status,
      {String ownerNote = ''}) async {
    await apiClient.respondToApplication(await _token(), applicationId, status,
        ownerNote: ownerNote);
  }

  @override
  Future<List<Tenancy>> getTenancies() async {
    final token = await _token();
    return _allPages((page) => apiClient.tenancies(token, page: page));
  }

  @override
  Future<Tenancy> getTenancy(String id) async =>
      apiClient.tenancy(await _token(), id);
  @override
  Future<Tenancy> createTenancyFromApplication(
      String applicationId, DateTime startDate) async {
    final applications = await getApplications();
    final application =
        applications.where((item) => item.id == applicationId).firstOrNull;
    if (application == null ||
        application.status != ApplicationStatus.accepted ||
        application.renter == null ||
        application.property == null) {
      throw const AppException(
          'An accepted application with renter and property details is required.',
          type: AppErrorType.validation);
    }
    return (await apiClient.createTenancy(await _token(), {
      'property_id': application.propertyId,
      'renter_mode': 'existing',
      'renter_id': application.renter!.id,
      'start_date': _date(startDate),
      'agreed_rent': application.property!.monthlyRent.toStringAsFixed(2),
    }))
        .tenancy;
  }

  @override
  Future<TenancyCreationResponse> createTenancyWithNewRenter({
    required String propertyId,
    required String renterName,
    String renterEmail = '',
    String renterPhone = '',
    required DateTime startDate,
    DateTime? endDate,
    required double agreedRent,
    double deposit = 0,
    int? billingDay,
    String notes = '',
  }) async =>
      apiClient.createTenancy(await _token(), {
        'property_id': propertyId,
        'renter_mode': 'new',
        'renter_name': renterName,
        if (renterEmail.isNotEmpty) 'renter_email': renterEmail,
        if (renterPhone.isNotEmpty) 'renter_phone': renterPhone,
        'start_date': _date(startDate),
        if (endDate != null) 'end_date': _date(endDate),
        'agreed_rent': agreedRent.toStringAsFixed(2),
        'deposit': deposit.toStringAsFixed(2),
        if (billingDay != null) 'billing_day': billingDay,
        if (notes.isNotEmpty) 'notes': notes,
      });

  @override
  Future<Tenancy> updateTenancy(Tenancy tenancy) async =>
      apiClient.updateTenancy(await _token(), tenancy.id, {
        'start_date': _date(tenancy.startDate),
        if (tenancy.endDate != null) 'end_date': _date(tenancy.endDate!),
        'agreed_rent': tenancy.monthlyRent.toStringAsFixed(2),
        'deposit': tenancy.deposit.toStringAsFixed(2),
        if (tenancy.billingDay != null) 'billing_day': tenancy.billingDay,
        'notes': tenancy.notes,
      });
  @override
  Future<void> endTenancy(String tenancyId,
      {required DateTime endDate,
      required PropertyStatus propertyStatus,
      String reason = ''}) async {
    await apiClient.endTenancy(await _token(), tenancyId,
        endDate: endDate, propertyStatus: propertyStatus, reason: reason);
  }

  @override
  Future<List<MonthlyRecord>> getMonthlyRecords() async {
    final token = await _token();
    return _allPages((page) => apiClient.monthlyRecords(token, page: page));
  }

  @override
  Future<MonthlyRecord> getMonthlyRecord(String id) async =>
      apiClient.monthlyRecord(await _token(), id);
  @override
  Future<MonthlyRecord> saveMonthlyRecord(MonthlyRecord record,
      {required bool submit,
      Map<PaymentCategory, List<String>> proofPaths = const {}}) async {
    final token = await _token();
    var saved = record.id.isEmpty
        ? await apiClient.createMonthlyRecord(token,
            tenancyId: record.tenancyId,
            periodMonth: record.month,
            amounts: record.amounts,
            notes: record.notes)
        : await apiClient.updateMonthlyRecord(token, record);
    for (final entry in proofPaths.entries) {
      if (entry.value.isNotEmpty) {
        saved = await apiClient.uploadMonthlyProofs(
            token, saved.id, entry.key, entry.value);
      }
    }
    if (submit) saved = await apiClient.submitMonthlyRecord(token, saved.id);
    return saved;
  }

  @override
  Future<void> approveMonthlyRecord(String id) async {
    await apiClient.approveMonthlyRecord(await _token(), id);
  }

  @override
  Future<void> rejectMonthlyRecord(String id, String reason) async {
    await apiClient.rejectMonthlyRecord(await _token(), id, reason);
  }

  @override
  Future<void> reopenMonthlyRecord(String id, String reason) async {
    await apiClient.reopenMonthlyRecord(await _token(), id, reason);
  }

  @override
  Future<List<MaintenanceRequest>> getMaintenanceRequests() async {
    final token = await _token();
    return _allPages(
        (page) => apiClient.maintenanceRequests(token, page: page));
  }

  @override
  Future<MaintenanceRequest> getMaintenanceRequest(String id) async =>
      apiClient.maintenanceRequest(await _token(), id);
  @override
  Future<MaintenanceRequest> createMaintenanceRequest(
          {required String tenancyId,
          required String title,
          required String description,
          required MaintenancePriority priority,
          List<String> attachmentPaths = const []}) async =>
      apiClient.createMaintenance(await _token(),
          tenancyId: tenancyId,
          title: title,
          description: description,
          priority: priority,
          attachmentPaths: attachmentPaths);
  @override
  Future<void> updateMaintenanceStatus(String id, MaintenanceStatus status,
      {String comment = ''}) async {
    await apiClient.updateMaintenanceStatus(await _token(), id, status,
        comment: comment);
  }

  @override
  Future<void> commentMaintenance(String id, String comment) async {
    await apiClient.commentMaintenance(await _token(), id, comment);
  }

  @override
  Future<List<AppNotification>> getNotifications({bool unread = false}) async {
    final token = await _token();
    return _allPages(
        (page) => apiClient.notifications(token, unread: unread, page: page));
  }

  @override
  Future<void> markNotificationsRead({List<String> ids = const []}) async {
    await apiClient.markNotificationsRead(await _token(), ids: ids);
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';
import '../../models/entities.dart';

class AuthSession {
  const AuthSession({required this.token, required this.user});
  final String token;
  final AppUser user;
}

class TenancyCreationResponse {
  const TenancyCreationResponse(
      {required this.tenancy, this.temporaryPassword = ''});

  final Tenancy tenancy;
  final String temporaryPassword;
}

class AppApiClient {
  AppApiClient({required String baseUrl, http.Client? httpClient})
      : _baseUrl = _normalizeBase(baseUrl),
        _httpClient = httpClient ?? http.Client();

  static const requestTimeout = Duration(seconds: 25);
  final String _baseUrl;
  final http.Client _httpClient;
  final StreamController<void> _unauthorizedController =
      StreamController<void>.broadcast();
  Stream<void> get unauthorized => _unauthorizedController.stream;
  String get apiBaseUrl => '$_baseUrl/api/v1';

  static String _normalizeBase(String value) {
    var result = value.trim();
    while (result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }
    if (result.endsWith('/api/v1')) {
      result = result.substring(0, result.length - 7);
    }
    return result;
  }

  Uri _uri(String path, [Map<String, Object?> query = const {}]) {
    final filtered = <String, String>{};
    for (final entry in query.entries) {
      if (entry.value != null && entry.value.toString().isNotEmpty) {
        filtered[entry.key] = entry.value.toString();
      }
    }
    return Uri.parse('$apiBaseUrl${path.startsWith('/') ? path : '/$path'}')
        .replace(queryParameters: filtered.isEmpty ? null : filtered);
  }

  Map<String, String> _headers([String? token, bool json = true]) => {
        'Accept': 'application/json',
        if (json) 'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> request(
    String path, {
    String method = 'GET',
    String? token,
    Map<String, Object?> query = const {},
    Map<String, Object?>? body,
  }) async {
    try {
      final request = http.Request(method, _uri(path, query))
        ..headers.addAll(_headers(token));
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _httpClient.send(request).timeout(requestTimeout);
      final response = await http.Response.fromStream(streamed);
      return _handle(response.statusCode, response.body);
    } on AppException {
      rethrow;
    } on TimeoutException {
      throw const AppException('The request timed out. Please try again.',
          type: AppErrorType.network);
    } on SocketException {
      throw const AppException(
          'No network connection. Check your connection and try again.',
          type: AppErrorType.network);
    } on http.ClientException {
      throw const AppException('Unable to connect to Rentra. Please try again.',
          type: AppErrorType.network);
    } on FormatException {
      throw const AppException('Rentra returned an invalid response.',
          type: AppErrorType.network);
    }
  }

  Future<Map<String, dynamic>> multipart(
    String path, {
    required String token,
    String method = 'POST',
    required Map<String, String> fields,
    Map<String, List<String>> files = const {},
  }) async {
    try {
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers.addAll(_headers(token, false));
      request.fields.addAll(fields);
      if (method != 'POST') request.fields['_method'] = method;
      for (final entry in files.entries) {
        for (final path in entry.value) {
          request.files
              .add(await http.MultipartFile.fromPath('${entry.key}[]', path));
        }
      }
      final streamed = await _httpClient.send(request).timeout(requestTimeout);
      final response = await http.Response.fromStream(streamed);
      return _handle(response.statusCode, response.body);
    } on AppException {
      rethrow;
    } on TimeoutException {
      throw const AppException('The upload timed out. Please try again.',
          type: AppErrorType.network);
    } on SocketException {
      throw const AppException(
          'The upload failed because the network is unavailable.',
          type: AppErrorType.network);
    } on FileSystemException {
      throw const AppException('A selected file is no longer available.',
          type: AppErrorType.validation);
    } on http.ClientException {
      throw const AppException('Unable to upload files to Rentra.',
          type: AppErrorType.network);
    }
  }

  Map<String, dynamic> _handle(int statusCode, String body) {
    Map<String, dynamic> decoded = {};
    if (body.trim().isNotEmpty) {
      final value = jsonDecode(body);
      if (value is Map) decoded = Map<String, dynamic>.from(value);
    }
    if (statusCode >= 200 && statusCode < 300) return decoded;
    final errors = <String, List<String>>{};
    final rawErrors = decoded['errors'];
    if (rawErrors is Map) {
      for (final entry in rawErrors.entries) {
        final value = entry.value;
        errors[entry.key.toString()] = value is Iterable
            ? value.map((item) => item.toString()).toList()
            : [value.toString()];
      }
    }
    if (statusCode == 401) _unauthorizedController.add(null);
    throw AppException.fromStatusCode(statusCode,
        message: decoded['message']?.toString(), errors: errors);
  }

  Map<String, dynamic> _data(Map<String, dynamic> envelope) =>
      jsonMap(envelope['data']);
  PagedResult<T> _page<T>(
      Map<String, dynamic> envelope, T Function(Map<String, dynamic>) parser) {
    final meta = jsonMap(envelope['meta']);
    return PagedResult(
        items:
            jsonMapList(envelope['data']).map(parser).toList(growable: false),
        pageInfo: PageInfo.fromJson(meta),
        extraMeta: meta);
  }

  Future<AuthSession> login(
      {required String identifier,
      required String password,
      required String deviceName}) async {
    final response = await request('/login', method: 'POST', body: {
      'identifier': identifier,
      'password': password,
      'device_name': deviceName
    });
    final token = response['token']?.toString() ?? '';
    final user = jsonMap(response['user']);
    if (token.isEmpty || user.isEmpty) {
      throw const AppException(
          'Login response did not contain a token and user.',
          type: AppErrorType.unauthorized);
    }
    return AuthSession(token: token, user: AppUser.fromJson(user));
  }

  Future<AppUser> me(String token) async =>
      AppUser.fromJson(_data(await request('/me', token: token)));
  Future<void> logout(String token) async {
    await request('/logout', token: token, method: 'POST');
  }

  Future<void> forgotPassword(String email) async {
    await request('/password/forgot', method: 'POST', body: {'email': email});
  }

  Future<PagedResult<RentalProperty>> listings(
      {String? token,
      String area = '',
      PropertyType? type,
      double? minRent,
      double? maxRent,
      int page = 1,
      int perPage = 12}) async {
    final response = await request('/listings', token: token, query: {
      'area': area,
      'type': type == null || type == PropertyType.unknown
          ? null
          : enumWireValue(type),
      'min_rent': minRent,
      'max_rent': maxRent,
      'page': page,
      'per_page': perPage
    });
    return _page(response, RentalProperty.fromJson);
  }

  Future<RentalProperty> listing(String id, {String? token}) async =>
      RentalProperty.fromJson(
          _data(await request('/listings/$id', token: token)));
  Future<PagedResult<RentalProperty>> properties(String token,
          {int page = 1, int perPage = 50}) async =>
      _page(
          await request('/properties',
              token: token, query: {'page': page, 'per_page': perPage}),
          RentalProperty.fromJson);
  Future<RentalProperty> property(String token, String id) async =>
      RentalProperty.fromJson(
          _data(await request('/properties/$id', token: token)));
  Future<RentalProperty> saveProperty(String token, RentalProperty property,
      {List<String> imagePaths = const [],
      List<String> videoPaths = const []}) async {
    final response = await multipart(
        property.id.isEmpty ? '/properties' : '/properties/${property.id}',
        token: token,
        method: property.id.isEmpty ? 'POST' : 'PATCH',
        fields: property.toRequestFields(),
        files: {'images': imagePaths, 'videos': videoPaths});
    return RentalProperty.fromJson(_data(response));
  }

  Future<PagedResult<RentalApplication>> applications(String token,
          {int page = 1, int perPage = 50}) async =>
      _page(
          await request('/applications',
              token: token, query: {'page': page, 'per_page': perPage}),
          RentalApplication.fromJson);
  Future<RentalApplication> apply(String token, String propertyId,
          {required String message, String contactPhone = ''}) async =>
      RentalApplication.fromJson(_data(await request(
          '/listings/$propertyId/applications',
          token: token,
          method: 'POST',
          body: {
            'message': message,
            if (contactPhone.isNotEmpty) 'contact_phone': contactPhone
          })));
  Future<RentalApplication> respondToApplication(
          String token, String applicationId, ApplicationStatus status,
          {String ownerNote = ''}) async =>
      RentalApplication.fromJson(_data(await request(
          '/applications/$applicationId',
          token: token,
          method: 'PATCH',
          body: {
            'status': enumWireValue(status),
            if (ownerNote.isNotEmpty) 'owner_note': ownerNote
          })));

  Future<PagedResult<Tenancy>> tenancies(String token,
          {int page = 1, int perPage = 50}) async =>
      _page(
          await request('/tenancies',
              token: token, query: {'page': page, 'per_page': perPage}),
          Tenancy.fromJson);
  Future<Tenancy> tenancy(String token, String id) async =>
      Tenancy.fromJson(_data(await request('/tenancies/$id', token: token)));
  Future<TenancyCreationResponse> createTenancy(
      String token, Map<String, Object?> body) async {
    final response =
        await request('/tenancies', token: token, method: 'POST', body: body);
    return TenancyCreationResponse(
      tenancy: Tenancy.fromJson(_data(response)),
      temporaryPassword: response['temporary_password']?.toString() ?? '',
    );
  }

  Future<Tenancy> updateTenancy(
          String token, String id, Map<String, Object?> body) async =>
      Tenancy.fromJson(_data(await request('/tenancies/$id',
          token: token, method: 'PATCH', body: body)));
  Future<Tenancy> endTenancy(String token, String id,
          {required DateTime endDate,
          required PropertyStatus propertyStatus,
          String reason = ''}) async =>
      Tenancy.fromJson(_data(await request('/tenancies/$id/end',
          token: token,
          method: 'PATCH',
          body: {
            'end_date': _date(endDate),
            'property_status': enumWireValue(propertyStatus),
            if (reason.isNotEmpty) 'reason': reason
          })));

  Future<PagedResult<MonthlyRecord>> monthlyRecords(String token,
          {MonthlyRecordStatus? status,
          String? tenancyId,
          int? year,
          int page = 1,
          int perPage = 50}) async =>
      _page(
          await request('/monthly-records', token: token, query: {
            'status': status == null || status == MonthlyRecordStatus.unknown
                ? null
                : enumWireValue(status),
            'tenancy_id': tenancyId,
            'year': year,
            'page': page,
            'per_page': perPage
          }),
          MonthlyRecord.fromJson);
  Future<MonthlyRecord> monthlyRecord(String token, String id) async =>
      MonthlyRecord.fromJson(
          _data(await request('/monthly-records/$id', token: token)));
  Future<MonthlyRecord> createMonthlyRecord(String token,
      {required String tenancyId,
      required String periodMonth,
      required Map<PaymentCategory, double> amounts,
      String notes = ''}) async {
    final body = <String, Object?>{
      'tenancy_id': tenancyId,
      'period_month': periodMonth,
      'notes': notes
    };
    for (final entry in amounts.entries) {
      if (entry.key != PaymentCategory.unknown) {
        body['${enumWireValue(entry.key)}_amount'] =
            entry.value.toStringAsFixed(2);
      }
    }
    return MonthlyRecord.fromJson(_data(await request('/monthly-records',
        token: token, method: 'POST', body: body)));
  }

  Future<MonthlyRecord> updateMonthlyRecord(
          String token, MonthlyRecord record) async =>
      MonthlyRecord.fromJson(_data(await request(
          '/monthly-records/${record.id}',
          token: token,
          method: 'PATCH',
          body: record.toAmountFields())));
  Future<MonthlyRecord> uploadMonthlyProofs(String token, String id,
          PaymentCategory category, List<String> paths) async =>
      MonthlyRecord.fromJson(_data(await multipart(
          '/monthly-records/$id/proofs',
          token: token,
          fields: {'category': enumWireValue(category)},
          files: {'files': paths})));
  Future<MonthlyRecord> submitMonthlyRecord(String token, String id) async =>
      MonthlyRecord.fromJson(_data(await request('/monthly-records/$id/submit',
          token: token, method: 'POST')));
  Future<MonthlyRecord> approveMonthlyRecord(String token, String id) async =>
      MonthlyRecord.fromJson(_data(await request('/monthly-records/$id/approve',
          token: token, method: 'POST')));
  Future<MonthlyRecord> rejectMonthlyRecord(
          String token, String id, String reason) async =>
      MonthlyRecord.fromJson(_data(await request('/monthly-records/$id/reject',
          token: token, method: 'POST', body: {'rejection_reason': reason})));
  Future<MonthlyRecord> reopenMonthlyRecord(
          String token, String id, String reason) async =>
      MonthlyRecord.fromJson(_data(await request('/monthly-records/$id/reopen',
          token: token, method: 'POST', body: {'reopen_reason': reason})));

  Future<PagedResult<MaintenanceRequest>> maintenanceRequests(String token,
          {MaintenanceStatus? status, int page = 1, int perPage = 50}) async =>
      _page(
          await request('/maintenance-requests', token: token, query: {
            'status': status == null || status == MaintenanceStatus.unknown
                ? null
                : enumWireValue(status),
            'page': page,
            'per_page': perPage
          }),
          MaintenanceRequest.fromJson);
  Future<MaintenanceRequest> maintenanceRequest(
          String token, String id) async =>
      MaintenanceRequest.fromJson(
          _data(await request('/maintenance-requests/$id', token: token)));
  Future<MaintenanceRequest> createMaintenance(String token,
          {required String tenancyId,
          required String title,
          required String description,
          required MaintenancePriority priority,
          List<String> attachmentPaths = const []}) async =>
      MaintenanceRequest.fromJson(
          _data(await multipart('/maintenance-requests', token: token, fields: {
        'tenancy_id': tenancyId,
        'title': title,
        'description': description,
        'priority': enumWireValue(priority)
      }, files: {
        'attachments': attachmentPaths
      })));
  Future<MaintenanceRequest> updateMaintenanceStatus(
          String token, String id, MaintenanceStatus status,
          {String comment = ''}) async =>
      MaintenanceRequest.fromJson(_data(await request(
          '/maintenance-requests/$id/status',
          token: token,
          method: 'PATCH',
          body: {
            'status': enumWireValue(status),
            if (comment.isNotEmpty) 'comment': comment
          })));
  Future<MaintenanceRequest> commentMaintenance(
          String token, String id, String comment) async =>
      MaintenanceRequest.fromJson(_data(await request(
          '/maintenance-requests/$id/comments',
          token: token,
          method: 'POST',
          body: {'comment': comment})));

  Future<PagedResult<AppNotification>> notifications(String token,
          {bool unread = false, int page = 1, int perPage = 50}) async =>
      _page(
          await request('/notifications', token: token, query: {
            'unread': unread ? 1 : null,
            'page': page,
            'per_page': perPage
          }),
          AppNotification.fromJson);
  Future<int> markNotificationsRead(String token,
      {List<String> ids = const []}) async {
    final response = await request('/notifications/read',
        token: token,
        method: 'POST',
        body: {if (ids.isNotEmpty) 'ids': ids.map(int.parse).toList()});
    return jsonInt(response['unread_count']);
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  void close() {
    _httpClient.close();
    _unauthorizedController.close();
  }
}

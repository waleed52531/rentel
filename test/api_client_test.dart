import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rent_settlement_app/core/api/app_api_client.dart';
import 'package:rent_settlement_app/core/errors/app_exception.dart';
import 'package:rent_settlement_app/models/entities.dart';

void main() {
  test('login sends Laravel identifier contract and parses role', () async {
    late http.Request captured;
    final client = AppApiClient(
        baseUrl: 'http://localhost:8000/api/v1/',
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response(
              jsonEncode({
                'token': 'token-1',
                'user': {
                  'id': 2,
                  'name': 'Owner',
                  'email': 'owner@example.com',
                  'phone': null,
                  'role': 'owner',
                  'status': 'active'
                }
              }),
              200,
              headers: {'content-type': 'application/json'});
        }));
    final session = await client.login(
        identifier: 'owner@example.com',
        password: 'secret',
        deviceName: 'test-device');
    expect(captured.url.toString(), 'http://localhost:8000/api/v1/login');
    expect(jsonDecode(captured.body), {
      'identifier': 'owner@example.com',
      'password': 'secret',
      'device_name': 'test-device'
    });
    expect(session.user.role, AppRole.owner);
  });

  test('Laravel 422 field errors are preserved', () async {
    final client = AppApiClient(
        baseUrl: 'http://localhost:8000',
        httpClient: MockClient((_) async => http.Response(
            jsonEncode({
              'message': 'Validation failed.',
              'errors': {
                'period_month': ['The month has already been taken.']
              }
            }),
            422)));
    expect(
        () => client.request('/monthly-records',
            method: 'POST', token: 'token', body: {}),
        throwsA(isA<AppException>().having(
            (error) => error.fieldErrors['period_month']?.first,
            'field error',
            'The month has already been taken.')));
  });

  test('listing query uses only supported Laravel filters', () async {
    late Uri uri;
    final client = AppApiClient(
        baseUrl: 'http://localhost:8000',
        httpClient: MockClient((request) async {
          uri = request.url;
          return http.Response(
              jsonEncode({
                'data': [],
                'meta': {
                  'current_page': 1,
                  'last_page': 1,
                  'per_page': 12,
                  'total': 0
                }
              }),
              200);
        }));
    await client.listings(
        area: 'Gulberg',
        type: PropertyType.guestHouse,
        minRent: 10000,
        maxRent: 50000);
    expect(uri.queryParameters, containsPair('type', 'guest_house'));
    expect(
        uri.queryParameters.keys,
        containsAll(
            ['area', 'type', 'min_rent', 'max_rent', 'page', 'per_page']));
  });

  test('unknown backend enum is preserved without crashing', () {
    final property = RentalProperty.fromJson({
      'id': 1,
      'title': 'Unknown',
      'type': 'villa',
      'rental_mode': 'whole',
      'rent_amount': '1.00',
      'area': 'A',
      'city': 'C',
      'address': 'X',
      'status': 'renovating',
      'publication_status': 'draft'
    });
    expect(property.type, PropertyType.unknown);
    expect(property.rawType, 'villa');
    expect(property.status, PropertyStatus.unknown);
    expect(property.rawStatus, 'renovating');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:rent_settlement_app/models/entities.dart';

void main() {
  group('AppRole', () {
    test('exposes the renter role expected by the product requirements', () {
      expect(AppRole.renter, isA<AppRole>());
      expect(AppRole.owner, isA<AppRole>());
      expect(AppRole.values, containsAll([AppRole.owner, AppRole.renter]));
    });
  });
}

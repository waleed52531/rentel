import 'package:flutter_test/flutter_test.dart';
import 'package:rent_settlement_app/app.dart';

void main() {
  testWidgets('Homvaro starts on the session-check splash', (tester) async {
    await tester.pumpWidget(const RentSettlementApp());
    expect(find.text('Homvaro'), findsOneWidget);
    expect(find.text('Find. Rent. Live Better.'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:rent_settlement_app/app.dart';

void main() {
  testWidgets('Rentra starts on the session-check splash', (tester) async {
    await tester.pumpWidget(const RentSettlementApp());
    expect(find.text('Rentra'), findsOneWidget);
    expect(find.text('Proof • Approval • Frozen History'), findsOneWidget);
  });
}

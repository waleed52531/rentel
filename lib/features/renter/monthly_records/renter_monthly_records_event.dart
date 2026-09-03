import '../../../models/entities.dart';

sealed class RenterMonthlyRecordsEvent {
  const RenterMonthlyRecordsEvent();
}

final class RenterMonthlyRecordsRequested extends RenterMonthlyRecordsEvent {
  const RenterMonthlyRecordsRequested();
}

final class RenterMonthlyRecordSaved extends RenterMonthlyRecordsEvent {
  const RenterMonthlyRecordSaved(this.record,
      {required this.submit, this.proofPaths = const {}});
  final MonthlyRecord record;
  final bool submit;
  final Map<PaymentCategory, List<String>> proofPaths;
}

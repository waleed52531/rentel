import '../../../models/entities.dart';

sealed class OwnerMonthlyRecordsEvent {
  const OwnerMonthlyRecordsEvent();
}

final class OwnerMonthlyRecordsRequested extends OwnerMonthlyRecordsEvent {
  const OwnerMonthlyRecordsRequested();
}

final class OwnerMonthlyRecordReviewed extends OwnerMonthlyRecordsEvent {
  const OwnerMonthlyRecordReviewed(this.recordId, this.status,
      {this.comment = ''});
  final String recordId;
  final MonthlyRecordStatus status;
  final String comment;
}

final class OwnerMonthlyRecordReopened extends OwnerMonthlyRecordsEvent {
  const OwnerMonthlyRecordReopened(this.recordId, this.reason);

  final String recordId;
  final String reason;
}

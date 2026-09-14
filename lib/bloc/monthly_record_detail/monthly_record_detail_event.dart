sealed class MonthlyRecordDetailEvent {
  const MonthlyRecordDetailEvent();
}

final class MonthlyRecordDetailRequested extends MonthlyRecordDetailEvent {
  const MonthlyRecordDetailRequested(this.id);
  final String id;
}

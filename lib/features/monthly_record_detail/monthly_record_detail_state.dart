import '../../models/entities.dart';

sealed class MonthlyRecordDetailState {
  const MonthlyRecordDetailState();
}

final class MonthlyRecordDetailInitial extends MonthlyRecordDetailState {
  const MonthlyRecordDetailInitial();
}

final class MonthlyRecordDetailLoading extends MonthlyRecordDetailState {
  const MonthlyRecordDetailLoading();
}

final class MonthlyRecordDetailLoaded extends MonthlyRecordDetailState {
  const MonthlyRecordDetailLoaded(this.record);
  final MonthlyRecord record;
}

final class MonthlyRecordDetailFailure extends MonthlyRecordDetailState {
  const MonthlyRecordDetailFailure(this.message);
  final String message;
}

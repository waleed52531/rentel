import '../../../models/entities.dart';

sealed class RenterMonthlyRecordsState {
  const RenterMonthlyRecordsState();
}

final class RenterMonthlyRecordsInitial extends RenterMonthlyRecordsState {
  const RenterMonthlyRecordsInitial();
}

final class RenterMonthlyRecordsLoading extends RenterMonthlyRecordsState {
  const RenterMonthlyRecordsLoading();
}

final class RenterMonthlyRecordsEmpty extends RenterMonthlyRecordsState {
  const RenterMonthlyRecordsEmpty();
}

final class RenterMonthlyRecordsLoaded extends RenterMonthlyRecordsState {
  const RenterMonthlyRecordsLoaded(this.records, {this.message});
  final List<MonthlyRecord> records;
  final String? message;
}

final class RenterMonthlyRecordsError extends RenterMonthlyRecordsState {
  const RenterMonthlyRecordsError(this.message);
  final String message;
}

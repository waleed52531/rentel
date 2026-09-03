import '../../../models/entities.dart';

sealed class OwnerMonthlyRecordsState {
  const OwnerMonthlyRecordsState();
}

final class OwnerMonthlyRecordsInitial extends OwnerMonthlyRecordsState {
  const OwnerMonthlyRecordsInitial();
}

final class OwnerMonthlyRecordsLoading extends OwnerMonthlyRecordsState {
  const OwnerMonthlyRecordsLoading();
}

final class OwnerMonthlyRecordsEmpty extends OwnerMonthlyRecordsState {
  const OwnerMonthlyRecordsEmpty();
}

final class OwnerMonthlyRecordsLoaded extends OwnerMonthlyRecordsState {
  const OwnerMonthlyRecordsLoaded(this.records, {this.message});
  final List<MonthlyRecord> records;
  final String? message;
}

final class OwnerMonthlyRecordsError extends OwnerMonthlyRecordsState {
  const OwnerMonthlyRecordsError(this.message);
  final String message;
}

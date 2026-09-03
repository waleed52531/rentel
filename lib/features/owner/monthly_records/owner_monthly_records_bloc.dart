import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../models/entities.dart';
import '../../../repositories/rental_repository.dart';
import 'owner_monthly_records_event.dart';
import 'owner_monthly_records_state.dart';

class OwnerMonthlyRecordsBloc
    extends Bloc<OwnerMonthlyRecordsEvent, OwnerMonthlyRecordsState> {
  OwnerMonthlyRecordsBloc(this._repository)
      : super(const OwnerMonthlyRecordsInitial()) {
    on<OwnerMonthlyRecordsRequested>(_load);
    on<OwnerMonthlyRecordReviewed>(_review);
    on<OwnerMonthlyRecordReopened>(_reopen);
  }

  Future<void> _reopen(OwnerMonthlyRecordReopened event,
      Emitter<OwnerMonthlyRecordsState> emit) async {
    try {
      await _repository.reopenMonthlyRecord(event.recordId, event.reason);
      await _refresh(emit, message: 'Record reopened for correction.');
    } catch (error) {
      emit(OwnerMonthlyRecordsError(readableError(error)));
    }
  }

  final RentalRepository _repository;
  Future<void> _load(OwnerMonthlyRecordsRequested event,
      Emitter<OwnerMonthlyRecordsState> emit) async {
    emit(const OwnerMonthlyRecordsLoading());
    await _refresh(emit);
  }

  Future<void> _review(OwnerMonthlyRecordReviewed event,
      Emitter<OwnerMonthlyRecordsState> emit) async {
    try {
      if (event.status == MonthlyRecordStatus.approved) {
        await _repository.approveMonthlyRecord(event.recordId);
      } else if (event.status == MonthlyRecordStatus.rejected) {
        await _repository.rejectMonthlyRecord(event.recordId, event.comment);
      }
      await _refresh(emit,
          message: event.status == MonthlyRecordStatus.approved
              ? 'Record approved.'
              : 'Record rejected for correction.');
    } catch (error) {
      emit(OwnerMonthlyRecordsError(readableError(error)));
    }
  }

  Future<void> _refresh(Emitter<OwnerMonthlyRecordsState> emit,
      {String? message}) async {
    try {
      final items = await _repository.getMonthlyRecords();
      emit(items.isEmpty
          ? const OwnerMonthlyRecordsEmpty()
          : OwnerMonthlyRecordsLoaded(items, message: message));
    } catch (error) {
      emit(OwnerMonthlyRecordsError(readableError(error)));
    }
  }
}

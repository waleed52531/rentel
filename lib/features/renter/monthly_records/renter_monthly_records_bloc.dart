import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../repositories/rental_repository.dart';
import 'renter_monthly_records_event.dart';
import 'renter_monthly_records_state.dart';

class RenterMonthlyRecordsBloc
    extends Bloc<RenterMonthlyRecordsEvent, RenterMonthlyRecordsState> {
  RenterMonthlyRecordsBloc(this._repository)
      : super(const RenterMonthlyRecordsInitial()) {
    on<RenterMonthlyRecordsRequested>(_load);
    on<RenterMonthlyRecordSaved>(_save);
  }
  final RentalRepository _repository;
  Future<void> _load(RenterMonthlyRecordsRequested event,
      Emitter<RenterMonthlyRecordsState> emit) async {
    emit(const RenterMonthlyRecordsLoading());
    await _refresh(emit);
  }

  Future<void> _save(RenterMonthlyRecordSaved event,
      Emitter<RenterMonthlyRecordsState> emit) async {
    try {
      await _repository.saveMonthlyRecord(event.record,
          submit: event.submit, proofPaths: event.proofPaths);
      await _refresh(emit,
          message: event.submit ? 'Monthly record submitted.' : 'Draft saved.');
    } catch (error) {
      emit(RenterMonthlyRecordsError(readableError(error)));
    }
  }

  Future<void> _refresh(Emitter<RenterMonthlyRecordsState> emit,
      {String? message}) async {
    try {
      final items = await _repository.getMonthlyRecords();
      emit(items.isEmpty
          ? const RenterMonthlyRecordsEmpty()
          : RenterMonthlyRecordsLoaded(items, message: message));
    } catch (error) {
      emit(RenterMonthlyRecordsError(readableError(error)));
    }
  }
}

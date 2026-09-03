import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/app_exception.dart';
import '../../repositories/rental_repository.dart';
import 'monthly_record_detail_event.dart';
import 'monthly_record_detail_state.dart';

class MonthlyRecordDetailBloc
    extends Bloc<MonthlyRecordDetailEvent, MonthlyRecordDetailState> {
  MonthlyRecordDetailBloc(this._repository)
      : super(const MonthlyRecordDetailInitial()) {
    on<MonthlyRecordDetailRequested>(_load);
  }
  final RentalRepository _repository;
  Future<void> _load(MonthlyRecordDetailRequested event,
      Emitter<MonthlyRecordDetailState> emit) async {
    emit(const MonthlyRecordDetailLoading());
    try {
      emit(MonthlyRecordDetailLoaded(
          await _repository.getMonthlyRecord(event.id)));
    } catch (error) {
      emit(MonthlyRecordDetailFailure(readableError(error)));
    }
  }
}

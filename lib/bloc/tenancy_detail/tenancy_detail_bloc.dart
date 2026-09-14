import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rent_settlement_app/data/errors/app_exception.dart';
import 'package:rent_settlement_app/repository/rental_repository.dart';
import 'package:rent_settlement_app/bloc/tenancy_detail/tenancy_detail_event.dart';
import 'package:rent_settlement_app/bloc/tenancy_detail/tenancy_detail_state.dart';

class TenancyDetailBloc extends Bloc<TenancyDetailEvent, TenancyDetailState> {
  TenancyDetailBloc(this._repository) : super(const TenancyDetailInitial()) {
    on<TenancyDetailRequested>(_load);
  }

  final RentalRepository _repository;

  Future<void> _load(
      TenancyDetailRequested event, Emitter<TenancyDetailState> emit) async {
    emit(const TenancyDetailLoading());
    try {
      emit(TenancyDetailLoaded(await _repository.getTenancy(event.id)));
    } catch (error) {
      emit(TenancyDetailFailure(readableError(error)));
    }
  }
}

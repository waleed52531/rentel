import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rent_settlement_app/data/errors/app_exception.dart';
import 'package:rent_settlement_app/repository/rental_repository.dart';
import 'package:rent_settlement_app/bloc/owner/properties/owner_property_detail_event.dart';
import 'package:rent_settlement_app/bloc/owner/properties/owner_property_detail_state.dart';

class OwnerPropertyDetailBloc
    extends Bloc<OwnerPropertyDetailEvent, OwnerPropertyDetailState> {
  OwnerPropertyDetailBloc(this._repository)
      : super(const OwnerPropertyDetailInitial()) {
    on<OwnerPropertyDetailRequested>(_load);
  }

  final RentalRepository _repository;

  Future<void> _load(OwnerPropertyDetailRequested event,
      Emitter<OwnerPropertyDetailState> emit) async {
    emit(const OwnerPropertyDetailLoading());
    try {
      emit(OwnerPropertyDetailLoaded(
          await _repository.getOwnerProperty(event.id)));
    } catch (error) {
      emit(OwnerPropertyDetailFailure(readableError(error)));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../repositories/rental_repository.dart';
import 'owner_property_detail_event.dart';
import 'owner_property_detail_state.dart';

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

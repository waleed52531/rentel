import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../repositories/rental_repository.dart';
import 'renter_listing_detail_event.dart';
import 'renter_listing_detail_state.dart';

class RenterListingDetailBloc
    extends Bloc<RenterListingDetailEvent, RenterListingDetailState> {
  RenterListingDetailBloc(this._repository)
      : super(const RenterListingDetailInitial()) {
    on<RenterListingDetailRequested>(_load);
  }
  final RentalRepository _repository;
  Future<void> _load(RenterListingDetailRequested event,
      Emitter<RenterListingDetailState> emit) async {
    emit(const RenterListingDetailLoading());
    try {
      emit(RenterListingDetailLoaded(await _repository.getListing(event.id)));
    } catch (error) {
      emit(RenterListingDetailFailure(readableError(error)));
    }
  }
}

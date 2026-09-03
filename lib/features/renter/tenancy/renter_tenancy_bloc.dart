import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../repositories/rental_repository.dart';
import 'renter_tenancy_event.dart';
import 'renter_tenancy_state.dart';

class RenterTenancyBloc extends Bloc<RenterTenancyEvent, RenterTenancyState> {
  RenterTenancyBloc(this._repository) : super(const RenterTenancyInitial()) {
    on<RenterTenancyRequested>(_load);
  }
  final RentalRepository _repository;
  Future<void> _load(
      RenterTenancyRequested event, Emitter<RenterTenancyState> emit) async {
    emit(const RenterTenancyLoading());
    try {
      final items = await _repository.getTenancies();
      emit(items.isEmpty
          ? const RenterTenancyEmpty()
          : RenterTenancyLoaded(items));
    } catch (error) {
      emit(RenterTenancyError(readableError(error)));
    }
  }
}

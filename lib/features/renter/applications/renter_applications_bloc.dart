import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../repositories/rental_repository.dart';
import 'renter_applications_event.dart';
import 'renter_applications_state.dart';

class RenterApplicationsBloc
    extends Bloc<RenterApplicationsEvent, RenterApplicationsState> {
  RenterApplicationsBloc(this._repository)
      : super(const RenterApplicationsInitial()) {
    on<RenterApplicationsRequested>(_load);
    on<RenterApplicationSubmitted>(_submit);
  }
  final RentalRepository _repository;
  Future<void> _load(RenterApplicationsRequested event,
      Emitter<RenterApplicationsState> emit) async {
    emit(const RenterApplicationsLoading());
    await _refresh(emit);
  }

  Future<void> _submit(RenterApplicationSubmitted event,
      Emitter<RenterApplicationsState> emit) async {
    try {
      await _repository.apply(event.propertyId, event.message,
          contactPhone: event.contactPhone);
      await _refresh(emit, message: 'Application submitted.');
    } catch (error) {
      emit(RenterApplicationsError(readableError(error)));
    }
  }

  Future<void> _refresh(Emitter<RenterApplicationsState> emit,
      {String? message}) async {
    try {
      final items = await _repository.getApplications();
      emit(items.isEmpty
          ? const RenterApplicationsEmpty()
          : RenterApplicationsLoaded(items, message: message));
    } catch (error) {
      emit(RenterApplicationsError(readableError(error)));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../repositories/rental_repository.dart';
import 'renter_maintenance_event.dart';
import 'renter_maintenance_state.dart';

class RenterMaintenanceBloc
    extends Bloc<RenterMaintenanceEvent, RenterMaintenanceState> {
  RenterMaintenanceBloc(this._repository)
      : super(const RenterMaintenanceInitial()) {
    on<RenterMaintenanceRequested>(_load);
    on<RenterMaintenanceCreated>(_create);
  }
  final RentalRepository _repository;
  Future<void> _load(RenterMaintenanceRequested event,
      Emitter<RenterMaintenanceState> emit) async {
    emit(const RenterMaintenanceLoading());
    await _refresh(emit);
  }

  Future<void> _create(RenterMaintenanceCreated event,
      Emitter<RenterMaintenanceState> emit) async {
    try {
      await _repository.createMaintenanceRequest(
          tenancyId: event.tenancyId,
          title: event.title,
          description: event.description,
          priority: event.priority,
          attachmentPaths: event.attachmentPaths);
      await _refresh(emit, message: 'Maintenance request created.');
    } catch (error) {
      emit(RenterMaintenanceError(readableError(error)));
    }
  }

  Future<void> _refresh(Emitter<RenterMaintenanceState> emit,
      {String? message}) async {
    try {
      final items = await _repository.getMaintenanceRequests();
      emit(items.isEmpty
          ? const RenterMaintenanceEmpty()
          : RenterMaintenanceLoaded(items, message: message));
    } catch (error) {
      emit(RenterMaintenanceError(readableError(error)));
    }
  }
}

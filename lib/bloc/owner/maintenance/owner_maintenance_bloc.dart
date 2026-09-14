import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rent_settlement_app/data/errors/app_exception.dart';
import 'package:rent_settlement_app/repository/rental_repository.dart';
import 'package:rent_settlement_app/bloc/owner/maintenance/owner_maintenance_event.dart';
import 'package:rent_settlement_app/bloc/owner/maintenance/owner_maintenance_state.dart';

class OwnerMaintenanceBloc
    extends Bloc<OwnerMaintenanceEvent, OwnerMaintenanceState> {
  OwnerMaintenanceBloc(this._repository)
      : super(const OwnerMaintenanceInitial()) {
    on<OwnerMaintenanceRequested>(_load);
    on<OwnerMaintenanceStatusChanged>(_status);
  }
  final RentalRepository _repository;
  Future<void> _load(OwnerMaintenanceRequested event,
      Emitter<OwnerMaintenanceState> emit) async {
    emit(const OwnerMaintenanceLoading());
    await _refresh(emit);
  }

  Future<void> _status(OwnerMaintenanceStatusChanged event,
      Emitter<OwnerMaintenanceState> emit) async {
    try {
      await _repository.updateMaintenanceStatus(event.requestId, event.status,
          comment: event.comment);
      await _refresh(emit, message: 'Maintenance status updated.');
    } catch (error) {
      emit(OwnerMaintenanceError(readableError(error)));
    }
  }

  Future<void> _refresh(Emitter<OwnerMaintenanceState> emit,
      {String? message}) async {
    try {
      final items = await _repository.getMaintenanceRequests();
      emit(items.isEmpty
          ? const OwnerMaintenanceEmpty()
          : OwnerMaintenanceLoaded(items, message: message));
    } catch (error) {
      emit(OwnerMaintenanceError(readableError(error)));
    }
  }
}

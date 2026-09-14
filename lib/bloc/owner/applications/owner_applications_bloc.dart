import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rent_settlement_app/data/errors/app_exception.dart';
import 'package:rent_settlement_app/model/entities.dart';
import 'package:rent_settlement_app/repository/rental_repository.dart';
import 'package:rent_settlement_app/bloc/owner/applications/owner_applications_event.dart';
import 'package:rent_settlement_app/bloc/owner/applications/owner_applications_state.dart';

class OwnerApplicationsBloc
    extends Bloc<OwnerApplicationsEvent, OwnerApplicationsState> {
  OwnerApplicationsBloc(this._repository)
      : super(const OwnerApplicationsInitial()) {
    on<OwnerApplicationsRequested>(_load);
    on<OwnerApplicationDecided>(_decide);
  }
  final RentalRepository _repository;
  Future<void> _load(OwnerApplicationsRequested event,
      Emitter<OwnerApplicationsState> emit) async {
    emit(const OwnerApplicationsLoading());
    await _refresh(emit);
  }

  Future<void> _decide(OwnerApplicationDecided event,
      Emitter<OwnerApplicationsState> emit) async {
    try {
      await _repository.updateApplicationStatus(
          event.applicationId, event.status,
          ownerNote: event.ownerNote);
      await _refresh(emit,
          message: 'Application ${event.status.displayLabel.toLowerCase()}.');
    } catch (error) {
      emit(OwnerApplicationsError(readableError(error)));
    }
  }

  Future<void> _refresh(Emitter<OwnerApplicationsState> emit,
      {String? message}) async {
    try {
      final items = await _repository.getApplications();
      emit(items.isEmpty
          ? const OwnerApplicationsEmpty()
          : OwnerApplicationsLoaded(items, message: message));
    } catch (error) {
      emit(OwnerApplicationsError(readableError(error)));
    }
  }
}

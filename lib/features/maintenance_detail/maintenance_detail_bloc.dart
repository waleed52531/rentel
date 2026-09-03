import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/app_exception.dart';
import '../../repositories/rental_repository.dart';
import 'maintenance_detail_event.dart';
import 'maintenance_detail_state.dart';

class MaintenanceDetailBloc
    extends Bloc<MaintenanceDetailEvent, MaintenanceDetailState> {
  MaintenanceDetailBloc(this._repository)
      : super(const MaintenanceDetailInitial()) {
    on<MaintenanceDetailRequested>(_load);
    on<MaintenanceCommentSubmitted>(_comment);
    on<MaintenanceDetailStatusChanged>(_status);
  }
  final RentalRepository _repository;
  Future<void> _load(MaintenanceDetailRequested event,
      Emitter<MaintenanceDetailState> emit) async {
    emit(const MaintenanceDetailLoading());
    await _refresh(event.id, emit);
  }

  Future<void> _comment(MaintenanceCommentSubmitted event,
      Emitter<MaintenanceDetailState> emit) async {
    try {
      await _repository.commentMaintenance(event.id, event.comment);
      await _refresh(event.id, emit, message: 'Comment added.');
    } catch (error) {
      emit(MaintenanceDetailFailure(readableError(error)));
    }
  }

  Future<void> _status(MaintenanceDetailStatusChanged event,
      Emitter<MaintenanceDetailState> emit) async {
    try {
      await _repository.updateMaintenanceStatus(event.id, event.status,
          comment: event.comment);
      await _refresh(event.id, emit, message: 'Status updated.');
    } catch (error) {
      emit(MaintenanceDetailFailure(readableError(error)));
    }
  }

  Future<void> _refresh(String id, Emitter<MaintenanceDetailState> emit,
      {String? message}) async {
    try {
      emit(MaintenanceDetailLoaded(await _repository.getMaintenanceRequest(id),
          message: message));
    } catch (error) {
      emit(MaintenanceDetailFailure(readableError(error)));
    }
  }
}

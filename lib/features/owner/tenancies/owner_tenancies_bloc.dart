import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../repositories/rental_repository.dart';
import 'owner_tenancies_event.dart';
import 'owner_tenancies_state.dart';

class OwnerTenanciesBloc
    extends Bloc<OwnerTenanciesEvent, OwnerTenanciesState> {
  OwnerTenanciesBloc(this._repository) : super(const OwnerTenanciesInitial()) {
    on<OwnerTenanciesRequested>(_load);
    on<OwnerTenancyAssigned>(_assign);
    on<OwnerNewRenterTenancyCreated>(_createNewRenter);
    on<OwnerTenancyUpdated>(_update);
    on<OwnerTenancyEnded>(_end);
  }

  Future<void> _createNewRenter(OwnerNewRenterTenancyCreated event,
      Emitter<OwnerTenanciesState> emit) async {
    try {
      final result = await _repository.createTenancyWithNewRenter(
        propertyId: event.propertyId,
        renterName: event.renterName,
        renterEmail: event.renterEmail,
        renterPhone: event.renterPhone,
        startDate: event.startDate,
        endDate: event.endDate,
        agreedRent: event.agreedRent,
        deposit: event.deposit,
        billingDay: event.billingDay,
        notes: event.notes,
      );
      await _refresh(emit,
          message: 'Renter account and tenancy created.',
          temporaryPassword: result.temporaryPassword);
    } catch (error) {
      emit(OwnerTenanciesError(readableError(error)));
    }
  }

  Future<void> _update(
      OwnerTenancyUpdated event, Emitter<OwnerTenanciesState> emit) async {
    try {
      await _repository.updateTenancy(event.tenancy);
      await _refresh(emit, message: 'Tenancy terms updated.');
    } catch (error) {
      emit(OwnerTenanciesError(readableError(error)));
    }
  }

  final RentalRepository _repository;
  Future<void> _load(
      OwnerTenanciesRequested event, Emitter<OwnerTenanciesState> emit) async {
    emit(const OwnerTenanciesLoading());
    await _refresh(emit);
  }

  Future<void> _assign(
      OwnerTenancyAssigned event, Emitter<OwnerTenanciesState> emit) async {
    try {
      await _repository.createTenancyFromApplication(
          event.applicationId, event.startDate);
      await _refresh(emit, message: 'Tenancy created successfully.');
    } catch (error) {
      emit(OwnerTenanciesError(readableError(error)));
    }
  }

  Future<void> _end(
      OwnerTenancyEnded event, Emitter<OwnerTenanciesState> emit) async {
    try {
      await _repository.endTenancy(event.tenancyId,
          endDate: event.endDate,
          propertyStatus: event.propertyStatus,
          reason: event.reason);
      await _refresh(emit, message: 'Tenancy ended.');
    } catch (error) {
      emit(OwnerTenanciesError(readableError(error)));
    }
  }

  Future<void> _refresh(Emitter<OwnerTenanciesState> emit,
      {String? message, String? temporaryPassword}) async {
    try {
      final items = await _repository.getTenancies();
      emit(items.isEmpty
          ? const OwnerTenanciesEmpty()
          : OwnerTenanciesLoaded(items,
              message: message, temporaryPassword: temporaryPassword));
    } catch (error) {
      emit(OwnerTenanciesError(readableError(error)));
    }
  }
}

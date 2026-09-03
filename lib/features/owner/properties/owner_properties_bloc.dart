import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../repositories/rental_repository.dart';
import 'owner_properties_event.dart';
import 'owner_properties_state.dart';

class OwnerPropertiesBloc
    extends Bloc<OwnerPropertiesEvent, OwnerPropertiesState> {
  OwnerPropertiesBloc(this._repository)
      : super(const OwnerPropertiesInitial()) {
    on<OwnerPropertiesRequested>(_load);
    on<OwnerPropertySaved>(_save);
  }
  final RentalRepository _repository;

  Future<void> _load(OwnerPropertiesRequested event,
      Emitter<OwnerPropertiesState> emit) async {
    emit(const OwnerPropertiesLoading());
    await _refresh(emit);
  }

  Future<void> _save(
      OwnerPropertySaved event, Emitter<OwnerPropertiesState> emit) async {
    try {
      await _repository.saveProperty(event.property,
          imagePaths: event.imagePaths, videoPaths: event.videoPaths);
      await _refresh(emit, message: 'Property saved.');
    } catch (error) {
      emit(OwnerPropertiesError(readableError(error)));
    }
  }

  Future<void> _refresh(Emitter<OwnerPropertiesState> emit,
      {String? message}) async {
    try {
      final items = await _repository.getOwnerProperties();
      emit(items.isEmpty
          ? const OwnerPropertiesEmpty()
          : OwnerPropertiesLoaded(items, message: message));
    } catch (error) {
      emit(OwnerPropertiesError(readableError(error)));
    }
  }
}

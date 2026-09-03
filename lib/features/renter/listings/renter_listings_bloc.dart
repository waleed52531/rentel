import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../repositories/rental_repository.dart';
import 'renter_listings_event.dart';
import 'renter_listings_state.dart';

class RenterListingsBloc
    extends Bloc<RenterListingsEvent, RenterListingsState> {
  RenterListingsBloc(this._repository) : super(const RenterListingsInitial()) {
    on<RenterListingsRequested>(_load);
  }
  final RentalRepository _repository;
  Future<void> _load(
      RenterListingsRequested event, Emitter<RenterListingsState> emit) async {
    emit(const RenterListingsLoading());
    await _refresh(emit, event);
  }

  Future<void> _refresh(
      Emitter<RenterListingsState> emit, RenterListingsRequested event) async {
    try {
      final allItems = await _repository.getPublishedListings(
          area: event.area,
          type: event.type,
          minRent: event.minRent,
          maxRent: event.maxRent);
      final query = event.query.trim().toLowerCase();
      final items = query.isEmpty
          ? allItems
          : allItems
              .where((item) =>
                  item.title.toLowerCase().contains(query) ||
                  item.area.toLowerCase().contains(query) ||
                  item.city.toLowerCase().contains(query))
              .toList(growable: false);
      emit(items.isEmpty
          ? const RenterListingsEmpty()
          : RenterListingsLoaded(items, query: event.query, area: event.area));
    } catch (error) {
      emit(RenterListingsError(readableError(error)));
    }
  }
}

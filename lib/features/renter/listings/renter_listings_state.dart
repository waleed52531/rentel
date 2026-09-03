import '../../../models/entities.dart';

sealed class RenterListingsState {
  const RenterListingsState();
}

final class RenterListingsInitial extends RenterListingsState {
  const RenterListingsInitial();
}

final class RenterListingsLoading extends RenterListingsState {
  const RenterListingsLoading();
}

final class RenterListingsEmpty extends RenterListingsState {
  const RenterListingsEmpty();
}

final class RenterListingsLoaded extends RenterListingsState {
  const RenterListingsLoaded(this.listings, {this.query = '', this.area = ''});
  final List<RentalProperty> listings;
  final String query;
  final String area;
}

final class RenterListingsError extends RenterListingsState {
  const RenterListingsError(this.message);
  final String message;
}

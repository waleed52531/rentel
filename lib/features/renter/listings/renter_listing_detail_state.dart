import '../../../models/entities.dart';

sealed class RenterListingDetailState {
  const RenterListingDetailState();
}

final class RenterListingDetailInitial extends RenterListingDetailState {
  const RenterListingDetailInitial();
}

final class RenterListingDetailLoading extends RenterListingDetailState {
  const RenterListingDetailLoading();
}

final class RenterListingDetailLoaded extends RenterListingDetailState {
  const RenterListingDetailLoaded(this.listing);
  final RentalProperty listing;
}

final class RenterListingDetailFailure extends RenterListingDetailState {
  const RenterListingDetailFailure(this.message);
  final String message;
}

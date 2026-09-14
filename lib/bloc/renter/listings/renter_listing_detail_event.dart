sealed class RenterListingDetailEvent {
  const RenterListingDetailEvent();
}

final class RenterListingDetailRequested extends RenterListingDetailEvent {
  const RenterListingDetailRequested(this.id);
  final String id;
}

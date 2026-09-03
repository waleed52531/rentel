sealed class RenterApplicationsEvent {
  const RenterApplicationsEvent();
}

final class RenterApplicationsRequested extends RenterApplicationsEvent {
  const RenterApplicationsRequested();
}

final class RenterApplicationSubmitted extends RenterApplicationsEvent {
  const RenterApplicationSubmitted(this.propertyId, this.message,
      {this.contactPhone = ''});
  final String propertyId;
  final String message;
  final String contactPhone;
}

import 'package:rent_settlement_app/model/entities.dart';

sealed class OwnerApplicationsEvent {
  const OwnerApplicationsEvent();
}

final class OwnerApplicationsRequested extends OwnerApplicationsEvent {
  const OwnerApplicationsRequested();
}

final class OwnerApplicationDecided extends OwnerApplicationsEvent {
  const OwnerApplicationDecided(this.applicationId, this.status,
      {this.ownerNote = ''});
  final String applicationId;
  final ApplicationStatus status;
  final String ownerNote;
}

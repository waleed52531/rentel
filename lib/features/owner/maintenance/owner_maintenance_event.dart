import '../../../models/entities.dart';

sealed class OwnerMaintenanceEvent {
  const OwnerMaintenanceEvent();
}

final class OwnerMaintenanceRequested extends OwnerMaintenanceEvent {
  const OwnerMaintenanceRequested();
}

final class OwnerMaintenanceStatusChanged extends OwnerMaintenanceEvent {
  const OwnerMaintenanceStatusChanged(this.requestId, this.status,
      {this.comment = ''});
  final String requestId;
  final MaintenanceStatus status;
  final String comment;
}

import '../../../models/entities.dart';

sealed class RenterMaintenanceEvent {
  const RenterMaintenanceEvent();
}

final class RenterMaintenanceRequested extends RenterMaintenanceEvent {
  const RenterMaintenanceRequested();
}

final class RenterMaintenanceCreated extends RenterMaintenanceEvent {
  const RenterMaintenanceCreated(
      {required this.tenancyId,
      required this.title,
      required this.description,
      required this.priority,
      this.attachmentPaths = const []});
  final String tenancyId;
  final String title;
  final String description;
  final MaintenancePriority priority;
  final List<String> attachmentPaths;
}

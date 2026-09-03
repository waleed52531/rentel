import '../../../models/entities.dart';

sealed class RenterMaintenanceState {
  const RenterMaintenanceState();
}

final class RenterMaintenanceInitial extends RenterMaintenanceState {
  const RenterMaintenanceInitial();
}

final class RenterMaintenanceLoading extends RenterMaintenanceState {
  const RenterMaintenanceLoading();
}

final class RenterMaintenanceEmpty extends RenterMaintenanceState {
  const RenterMaintenanceEmpty();
}

final class RenterMaintenanceLoaded extends RenterMaintenanceState {
  const RenterMaintenanceLoaded(this.requests, {this.message});
  final List<MaintenanceRequest> requests;
  final String? message;
}

final class RenterMaintenanceError extends RenterMaintenanceState {
  const RenterMaintenanceError(this.message);
  final String message;
}

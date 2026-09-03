import '../../../models/entities.dart';

sealed class OwnerMaintenanceState {
  const OwnerMaintenanceState();
}

final class OwnerMaintenanceInitial extends OwnerMaintenanceState {
  const OwnerMaintenanceInitial();
}

final class OwnerMaintenanceLoading extends OwnerMaintenanceState {
  const OwnerMaintenanceLoading();
}

final class OwnerMaintenanceEmpty extends OwnerMaintenanceState {
  const OwnerMaintenanceEmpty();
}

final class OwnerMaintenanceLoaded extends OwnerMaintenanceState {
  const OwnerMaintenanceLoaded(this.requests, {this.message});
  final List<MaintenanceRequest> requests;
  final String? message;
}

final class OwnerMaintenanceError extends OwnerMaintenanceState {
  const OwnerMaintenanceError(this.message);
  final String message;
}

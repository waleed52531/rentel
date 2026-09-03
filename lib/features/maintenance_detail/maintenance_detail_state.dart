import '../../models/entities.dart';

sealed class MaintenanceDetailState {
  const MaintenanceDetailState();
}

final class MaintenanceDetailInitial extends MaintenanceDetailState {
  const MaintenanceDetailInitial();
}

final class MaintenanceDetailLoading extends MaintenanceDetailState {
  const MaintenanceDetailLoading();
}

final class MaintenanceDetailLoaded extends MaintenanceDetailState {
  const MaintenanceDetailLoaded(this.request, {this.message});
  final MaintenanceRequest request;
  final String? message;
}

final class MaintenanceDetailFailure extends MaintenanceDetailState {
  const MaintenanceDetailFailure(this.message);
  final String message;
}

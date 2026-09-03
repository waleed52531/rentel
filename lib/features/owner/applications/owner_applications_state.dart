import '../../../models/entities.dart';

sealed class OwnerApplicationsState {
  const OwnerApplicationsState();
}

final class OwnerApplicationsInitial extends OwnerApplicationsState {
  const OwnerApplicationsInitial();
}

final class OwnerApplicationsLoading extends OwnerApplicationsState {
  const OwnerApplicationsLoading();
}

final class OwnerApplicationsEmpty extends OwnerApplicationsState {
  const OwnerApplicationsEmpty();
}

final class OwnerApplicationsLoaded extends OwnerApplicationsState {
  const OwnerApplicationsLoaded(this.applications, {this.message});
  final List<RentalApplication> applications;
  final String? message;
}

final class OwnerApplicationsError extends OwnerApplicationsState {
  const OwnerApplicationsError(this.message);
  final String message;
}

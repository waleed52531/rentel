import '../../../models/entities.dart';

sealed class RenterApplicationsState {
  const RenterApplicationsState();
}

final class RenterApplicationsInitial extends RenterApplicationsState {
  const RenterApplicationsInitial();
}

final class RenterApplicationsLoading extends RenterApplicationsState {
  const RenterApplicationsLoading();
}

final class RenterApplicationsEmpty extends RenterApplicationsState {
  const RenterApplicationsEmpty();
}

final class RenterApplicationsLoaded extends RenterApplicationsState {
  const RenterApplicationsLoaded(this.applications, {this.message});
  final List<RentalApplication> applications;
  final String? message;
}

final class RenterApplicationsError extends RenterApplicationsState {
  const RenterApplicationsError(this.message);
  final String message;
}

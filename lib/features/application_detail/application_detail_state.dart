import '../../models/entities.dart';

sealed class ApplicationDetailState {
  const ApplicationDetailState();
}

final class ApplicationDetailInitial extends ApplicationDetailState {
  const ApplicationDetailInitial();
}

final class ApplicationDetailLoading extends ApplicationDetailState {
  const ApplicationDetailLoading();
}

final class ApplicationDetailLoaded extends ApplicationDetailState {
  const ApplicationDetailLoaded(this.application);

  final RentalApplication application;
}

final class ApplicationDetailFailure extends ApplicationDetailState {
  const ApplicationDetailFailure(this.message);

  final String message;
}

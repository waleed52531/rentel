import '../../../models/entities.dart';

sealed class OwnerTenanciesState {
  const OwnerTenanciesState();
}

final class OwnerTenanciesInitial extends OwnerTenanciesState {
  const OwnerTenanciesInitial();
}

final class OwnerTenanciesLoading extends OwnerTenanciesState {
  const OwnerTenanciesLoading();
}

final class OwnerTenanciesEmpty extends OwnerTenanciesState {
  const OwnerTenanciesEmpty();
}

final class OwnerTenanciesLoaded extends OwnerTenanciesState {
  const OwnerTenanciesLoaded(this.tenancies,
      {this.message, this.temporaryPassword});
  final List<Tenancy> tenancies;
  final String? message;
  final String? temporaryPassword;
}

final class OwnerTenanciesError extends OwnerTenanciesState {
  const OwnerTenanciesError(this.message);
  final String message;
}

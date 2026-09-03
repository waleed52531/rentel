import '../../../models/entities.dart';

sealed class RenterTenancyState {
  const RenterTenancyState();
}

final class RenterTenancyInitial extends RenterTenancyState {
  const RenterTenancyInitial();
}

final class RenterTenancyLoading extends RenterTenancyState {
  const RenterTenancyLoading();
}

final class RenterTenancyEmpty extends RenterTenancyState {
  const RenterTenancyEmpty();
}

final class RenterTenancyLoaded extends RenterTenancyState {
  const RenterTenancyLoaded(this.tenancies);
  final List<Tenancy> tenancies;
}

final class RenterTenancyError extends RenterTenancyState {
  const RenterTenancyError(this.message);
  final String message;
}

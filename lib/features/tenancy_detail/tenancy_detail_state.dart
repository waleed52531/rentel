import '../../models/entities.dart';

sealed class TenancyDetailState {
  const TenancyDetailState();
}

final class TenancyDetailInitial extends TenancyDetailState {
  const TenancyDetailInitial();
}

final class TenancyDetailLoading extends TenancyDetailState {
  const TenancyDetailLoading();
}

final class TenancyDetailLoaded extends TenancyDetailState {
  const TenancyDetailLoaded(this.tenancy);

  final Tenancy tenancy;
}

final class TenancyDetailFailure extends TenancyDetailState {
  const TenancyDetailFailure(this.message);

  final String message;
}

import '../../../models/entities.dart';

sealed class OwnerPropertyDetailState {
  const OwnerPropertyDetailState();
}

final class OwnerPropertyDetailInitial extends OwnerPropertyDetailState {
  const OwnerPropertyDetailInitial();
}

final class OwnerPropertyDetailLoading extends OwnerPropertyDetailState {
  const OwnerPropertyDetailLoading();
}

final class OwnerPropertyDetailLoaded extends OwnerPropertyDetailState {
  const OwnerPropertyDetailLoaded(this.property);

  final RentalProperty property;
}

final class OwnerPropertyDetailFailure extends OwnerPropertyDetailState {
  const OwnerPropertyDetailFailure(this.message);

  final String message;
}

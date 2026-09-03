import '../../../models/entities.dart';

sealed class OwnerPropertiesState {
  const OwnerPropertiesState();
}

final class OwnerPropertiesInitial extends OwnerPropertiesState {
  const OwnerPropertiesInitial();
}

final class OwnerPropertiesLoading extends OwnerPropertiesState {
  const OwnerPropertiesLoading();
}

final class OwnerPropertiesEmpty extends OwnerPropertiesState {
  const OwnerPropertiesEmpty();
}

final class OwnerPropertiesLoaded extends OwnerPropertiesState {
  const OwnerPropertiesLoaded(this.properties, {this.message});
  final List<RentalProperty> properties;
  final String? message;
}

final class OwnerPropertiesError extends OwnerPropertiesState {
  const OwnerPropertiesError(this.message, {this.canRetry = true});
  final String message;
  final bool canRetry;
}

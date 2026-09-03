import '../../../models/entities.dart';

sealed class OwnerPropertiesEvent {
  const OwnerPropertiesEvent();
}

final class OwnerPropertiesRequested extends OwnerPropertiesEvent {
  const OwnerPropertiesRequested();
}

final class OwnerPropertySaved extends OwnerPropertiesEvent {
  const OwnerPropertySaved(this.property,
      {this.imagePaths = const [], this.videoPaths = const []});
  final RentalProperty property;
  final List<String> imagePaths;
  final List<String> videoPaths;
}

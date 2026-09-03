import '../../../models/entities.dart';

sealed class RenterListingsEvent {
  const RenterListingsEvent();
}

final class RenterListingsRequested extends RenterListingsEvent {
  const RenterListingsRequested(
      {this.query = '', this.area = '', this.type, this.minRent, this.maxRent});
  final String query;
  final String area;
  final PropertyType? type;
  final double? minRent;
  final double? maxRent;
}

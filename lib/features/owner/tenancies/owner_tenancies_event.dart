import '../../../models/entities.dart';

sealed class OwnerTenanciesEvent {
  const OwnerTenanciesEvent();
}

final class OwnerTenanciesRequested extends OwnerTenanciesEvent {
  const OwnerTenanciesRequested();
}

final class OwnerTenancyAssigned extends OwnerTenanciesEvent {
  const OwnerTenancyAssigned(this.applicationId, this.startDate);
  final String applicationId;
  final DateTime startDate;
}

final class OwnerNewRenterTenancyCreated extends OwnerTenanciesEvent {
  const OwnerNewRenterTenancyCreated({
    required this.propertyId,
    required this.renterName,
    this.renterEmail = '',
    this.renterPhone = '',
    required this.startDate,
    this.endDate,
    required this.agreedRent,
    this.deposit = 0,
    this.billingDay,
    this.notes = '',
  });

  final String propertyId;
  final String renterName;
  final String renterEmail;
  final String renterPhone;
  final DateTime startDate;
  final DateTime? endDate;
  final double agreedRent;
  final double deposit;
  final int? billingDay;
  final String notes;
}

final class OwnerTenancyUpdated extends OwnerTenanciesEvent {
  const OwnerTenancyUpdated(this.tenancy);
  final Tenancy tenancy;
}

final class OwnerTenancyEnded extends OwnerTenanciesEvent {
  const OwnerTenancyEnded(this.tenancyId,
      {required this.endDate, required this.propertyStatus, this.reason = ''});
  final String tenancyId;
  final DateTime endDate;
  final PropertyStatus propertyStatus;
  final String reason;
}

import 'package:flutter/material.dart';

enum AppLanguage { english, urdu }
enum AppRole { tenant, owner }
enum AuthMethod { phoneOtp, emailPassword }
enum RecordStatus { draft, submitted, underReview, rejected, approved, frozen }
enum BillType { electricity, water, gas, other }
enum NotificationType { submission, approval, rejection, reminder, comment }

extension RecordStatusView on RecordStatus {
  String get label => switch (this) {
        RecordStatus.draft => 'Draft',
        RecordStatus.submitted => 'Submitted',
        RecordStatus.underReview => 'Under Review',
        RecordStatus.rejected => 'Rejected',
        RecordStatus.approved => 'Approved',
        RecordStatus.frozen => 'Frozen',
      };

  Color get color => switch (this) {
        RecordStatus.draft => Colors.grey,
        RecordStatus.submitted => Colors.orange,
        RecordStatus.underReview => Colors.blue,
        RecordStatus.rejected => Colors.red,
        RecordStatus.approved => Colors.green,
        RecordStatus.frozen => Colors.teal,
      };

  bool get isLocked =>
      this == RecordStatus.submitted || this == RecordStatus.approved || this == RecordStatus.frozen;

  bool get canTenantEdit => this == RecordStatus.draft || this == RecordStatus.rejected;
}

class BillEntry {
  BillEntry({
    required this.type,
    required this.amount,
    required this.deductionAmount,
    required this.reason,
    this.note = '',
  });

  final BillType type;
  final double amount;
  final double deductionAmount;
  final String reason;
  final String note;
}

class ProofImage {
  ProofImage({
    required this.id,
    required this.billType,
    required this.label,
    required this.uploadedAt,
  });

  final String id;
  final BillType billType;
  final String label;
  final DateTime uploadedAt;
}

class ReviewComment {
  ReviewComment({
    required this.id,
    required this.userRole,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final AppRole userRole;
  final String message;
  final DateTime createdAt;
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.userRole,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final AppRole userRole;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool read;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        userRole: userRole,
        title: title,
        body: body,
        type: type,
        createdAt: createdAt,
        read: read ?? this.read,
      );
}

class MonthlyRecord {
  MonthlyRecord({
    required this.id,
    required this.month,
    required this.propertyTitle,
    required this.baseRent,
    required this.bills,
    required this.notes,
    required this.proofs,
    required this.status,
    required this.createdAt,
    this.submittedAt,
    this.approvedAt,
    this.frozenAt,
    this.submittedBy = AppRole.tenant,
    this.approvedBy,
    this.comments = const <ReviewComment>[],
  });

  final String id;
  final String month;
  final String propertyTitle;
  final double baseRent;
  final List<BillEntry> bills;
  final String notes;
  final List<ProofImage> proofs;
  final RecordStatus status;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? frozenAt;
  final AppRole submittedBy;
  final AppRole? approvedBy;
  final List<ReviewComment> comments;

  double get totalBillAmount => bills.fold(0, (sum, bill) => sum + bill.amount);
  double get totalDeductions => bills.fold(0, (sum, bill) => sum + bill.deductionAmount);
  double get finalPayable => (baseRent + totalBillAmount) - totalDeductions;

  MonthlyRecord copyWith({
    String? month,
    double? baseRent,
    List<BillEntry>? bills,
    String? notes,
    List<ProofImage>? proofs,
    RecordStatus? status,
    DateTime? submittedAt,
    DateTime? approvedAt,
    DateTime? frozenAt,
    AppRole? approvedBy,
    List<ReviewComment>? comments,
  }) {
    return MonthlyRecord(
      id: id,
      month: month ?? this.month,
      propertyTitle: propertyTitle,
      baseRent: baseRent ?? this.baseRent,
      bills: bills ?? this.bills,
      notes: notes ?? this.notes,
      proofs: proofs ?? this.proofs,
      status: status ?? this.status,
      createdAt: createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      frozenAt: frozenAt ?? this.frozenAt,
      submittedBy: submittedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      comments: comments ?? this.comments,
    );
  }
}

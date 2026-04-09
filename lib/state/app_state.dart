import 'package:flutter/material.dart';

import '../models/entities.dart';

class AppController extends ChangeNotifier {
  AppLanguage language = AppLanguage.english;

  final List<MonthlyRecord> _records = <MonthlyRecord>[];
  final List<String> _auditLogs = <String>[];
  final List<AppNotification> _notifications = <AppNotification>[];

  List<MonthlyRecord> get records => List.unmodifiable(_records);
  List<String> get auditLogs => List.unmodifiable(_auditLogs.reversed);

  List<AppNotification> notificationsFor(AppRole role) =>
      _notifications.where((n) => n.userRole == role).toList().reversed.toList();

  List<MonthlyRecord> recordsForStatus(RecordStatus status) =>
      _records.where((r) => r.status == status).toList();

  bool hasMonthRecord(String month) => _records.any((r) => r.month.toLowerCase() == month.toLowerCase());

  void setLanguage(AppLanguage value) {
    language = value;
    notifyListeners();
  }

  void createDraftOrSubmit({
    required String month,
    required double baseRent,
    required List<BillEntry> bills,
    required List<ProofImage> proofs,
    required String notes,
    required bool submit,
  }) {
    if (hasMonthRecord(month)) {
      throw StateError('Only one active monthly record per month is allowed.');
    }
    final now = DateTime.now();
    final status = submit ? RecordStatus.submitted : RecordStatus.draft;

    final record = MonthlyRecord(
      id: 'rec_${now.microsecondsSinceEpoch}',
      month: month,
      propertyTitle: 'House A',
      baseRent: baseRent,
      bills: bills,
      notes: notes,
      proofs: proofs,
      status: status,
      createdAt: now,
      submittedAt: submit ? now : null,
    );

    _records.add(record);
    _log('created ${record.month} as ${record.status.label}');

    if (submit) {
      _notify(
        role: AppRole.tenant,
        title: 'Submission successful',
        body: '${record.month} has been submitted to owner.',
        type: NotificationType.submission,
      );
      _notify(
        role: AppRole.owner,
        title: 'New month submitted',
        body: 'Please review ${record.month}.',
        type: NotificationType.submission,
      );
      _log('submitted ${record.month}');
    }

    notifyListeners();
  }

  void resubmitRejected({
    required String recordId,
    required double baseRent,
    required List<BillEntry> bills,
    required List<ProofImage> proofs,
    required String notes,
  }) {
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index < 0) return;

    final old = _records[index];
    if (!old.status.canTenantEdit) {
      throw StateError('This record cannot be edited in ${old.status.label}.');
    }

    final updated = old.copyWith(
      baseRent: baseRent,
      bills: bills,
      proofs: proofs,
      notes: notes,
      status: RecordStatus.submitted,
      submittedAt: DateTime.now(),
    );
    _records[index] = updated;
    _log('resubmitted ${updated.month}');

    _notify(
      role: AppRole.owner,
      title: 'Resubmission received',
      body: '${updated.month} has been resubmitted.',
      type: NotificationType.submission,
    );

    notifyListeners();
  }

  void markUnderReview(String recordId) {
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index < 0) return;
    final old = _records[index];
    if (old.status != RecordStatus.submitted) return;
    _records[index] = old.copyWith(status: RecordStatus.underReview);
    _log('under review ${old.month}');
    notifyListeners();
  }

  void approveAndFreeze(String recordId, {String? comment}) {
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index < 0) return;

    final old = _records[index];
    final now = DateTime.now();
    final comments = [...old.comments];
    if (comment != null && comment.trim().isNotEmpty) {
      comments.add(
        ReviewComment(
          id: 'c_${now.microsecondsSinceEpoch}',
          userRole: AppRole.owner,
          message: comment.trim(),
          createdAt: now,
        ),
      );
    }

    _records[index] = old.copyWith(
      status: RecordStatus.frozen,
      approvedAt: now,
      frozenAt: now,
      approvedBy: AppRole.owner,
      comments: comments,
    );

    _log('approved and frozen ${old.month}');
    _notify(
      role: AppRole.tenant,
      title: 'Owner approved month',
      body: '${old.month} is approved and frozen.',
      type: NotificationType.approval,
    );
    notifyListeners();
  }

  void reject(String recordId, {required String reason}) {
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index < 0) return;

    final old = _records[index];
    final now = DateTime.now();
    final comments = [
      ...old.comments,
      ReviewComment(
        id: 'c_${now.microsecondsSinceEpoch}',
        userRole: AppRole.owner,
        message: reason,
        createdAt: now,
      ),
    ];

    _records[index] = old.copyWith(status: RecordStatus.rejected, comments: comments);

    _log('rejected ${old.month}');
    _notify(
      role: AppRole.tenant,
      title: 'Owner rejected month',
      body: '${old.month} was rejected. Reason: $reason',
      type: NotificationType.rejection,
    );
    notifyListeners();
  }

  void markAllRead(AppRole role) {
    for (var i = 0; i < _notifications.length; i++) {
      final item = _notifications[i];
      if (item.userRole == role && !item.read) {
        _notifications[i] = item.copyWith(read: true);
      }
    }
    notifyListeners();
  }

  void _notify({
    required AppRole role,
    required String title,
    required String body,
    required NotificationType type,
  }) {
    _notifications.add(
      AppNotification(
        id: 'n_${DateTime.now().microsecondsSinceEpoch}',
        userRole: role,
        title: title,
        body: body,
        type: type,
        createdAt: DateTime.now(),
      ),
    );
  }

  void _log(String text) {
    final timestamp = DateTime.now().toIso8601String();
    _auditLogs.add('$timestamp - $text');
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({super.key, required AppController controller, required super.child})
      : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }
}

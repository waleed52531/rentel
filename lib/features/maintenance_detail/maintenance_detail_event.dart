import '../../models/entities.dart';

sealed class MaintenanceDetailEvent {
  const MaintenanceDetailEvent();
}

final class MaintenanceDetailRequested extends MaintenanceDetailEvent {
  const MaintenanceDetailRequested(this.id);
  final String id;
}

final class MaintenanceCommentSubmitted extends MaintenanceDetailEvent {
  const MaintenanceCommentSubmitted(this.id, this.comment);
  final String id;
  final String comment;
}

final class MaintenanceDetailStatusChanged extends MaintenanceDetailEvent {
  const MaintenanceDetailStatusChanged(this.id, this.status,
      {this.comment = ''});
  final String id;
  final MaintenanceStatus status;
  final String comment;
}

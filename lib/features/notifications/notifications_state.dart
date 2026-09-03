import '../../models/entities.dart';

sealed class NotificationsState {
  const NotificationsState();
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsEmpty extends NotificationsState {
  const NotificationsEmpty();
}

final class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded(this.items, {this.message});
  final List<AppNotification> items;
  final String? message;
}

final class NotificationsFailure extends NotificationsState {
  const NotificationsFailure(this.message);
  final String message;
}

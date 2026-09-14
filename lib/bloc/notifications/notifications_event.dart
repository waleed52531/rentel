sealed class NotificationsEvent {
  const NotificationsEvent();
}

final class NotificationsRequested extends NotificationsEvent {
  const NotificationsRequested({this.unreadOnly = false});
  final bool unreadOnly;
}

final class NotificationReadRequested extends NotificationsEvent {
  const NotificationReadRequested(this.id);
  final String id;
}

final class AllNotificationsReadRequested extends NotificationsEvent {
  const AllNotificationsReadRequested();
}

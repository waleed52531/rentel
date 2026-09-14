sealed class ApplicationDetailEvent {
  const ApplicationDetailEvent();
}

final class ApplicationDetailRequested extends ApplicationDetailEvent {
  const ApplicationDetailRequested(this.id);

  final String id;
}

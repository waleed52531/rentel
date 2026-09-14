sealed class OwnerPropertyDetailEvent {
  const OwnerPropertyDetailEvent();
}

final class OwnerPropertyDetailRequested extends OwnerPropertyDetailEvent {
  const OwnerPropertyDetailRequested(this.id);

  final String id;
}

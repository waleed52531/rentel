sealed class TenancyDetailEvent {
  const TenancyDetailEvent();
}

final class TenancyDetailRequested extends TenancyDetailEvent {
  const TenancyDetailRequested(this.id);

  final String id;
}

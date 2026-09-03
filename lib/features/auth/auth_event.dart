sealed class AuthEvent {
  const AuthEvent();
}

final class AuthSessionChecked extends AuthEvent {
  const AuthSessionChecked();
}

final class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted({
    required this.identifier,
    required this.password,
  });
  final String identifier;
  final String password;
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}

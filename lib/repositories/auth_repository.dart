import '../core/api/app_api_client.dart';
import '../core/errors/app_exception.dart';
import '../core/storage/secure_session_store.dart';
import '../models/entities.dart';

class AuthRepository {
  const AuthRepository({
    required this.apiClient,
    required this.sessionStore,
  });

  final AppApiClient apiClient;
  final SecureSessionStore sessionStore;

  Future<AppUser?> restoreSession() async {
    final token = await sessionStore.readToken();
    if (token == null || token.isEmpty) return null;

    try {
      final user = await apiClient.me(token);
      await sessionStore.saveUser(user.toCacheJson());
      return user;
    } on AppException catch (error) {
      if (error.type == AppErrorType.unauthorized) {
        await sessionStore.clear();
        return null;
      }
      rethrow;
    }
  }

  Future<AppUser> login({
    required String identifier,
    required String password,
  }) async {
    final session = await apiClient.login(
      identifier: identifier,
      password: password,
      deviceName: 'rentra-flutter-${DateTime.now().millisecondsSinceEpoch}',
    );

    await sessionStore.saveToken(session.token);
    await sessionStore.saveUser(session.user.toCacheJson());

    return session.user;
  }

  Future<void> logout() async {
    final token = await sessionStore.readToken();
    try {
      if (token != null && token.isNotEmpty) await apiClient.logout(token);
    } finally {
      await sessionStore.clear();
    }
  }

  Future<void> clearSession() => sessionStore.clear();
}

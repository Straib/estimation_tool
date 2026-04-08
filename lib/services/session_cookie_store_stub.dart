import 'session_cookie_store.dart';

SessionCookieStore createCookieStore() => _NoopSessionCookieStore();

class _NoopSessionCookieStore implements SessionCookieStore {
  @override
  Future<void> clear() async {}

  @override
  Future<SessionCookieData?> read() async => null;

  @override
  Future<void> write({required String sessionId, required String userId}) async {}
}

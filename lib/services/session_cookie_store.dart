import 'session_cookie_store_stub.dart'
    if (dart.library.html) 'session_cookie_store_web.dart';

class SessionCookieData {
  const SessionCookieData({required this.sessionId, required this.userId});

  final String sessionId;
  final String userId;
}

abstract class SessionCookieStore {
  Future<SessionCookieData?> read();

  Future<void> write({required String sessionId, required String userId});

  Future<void> clear();
}

SessionCookieStore createSessionCookieStore() => createCookieStore();

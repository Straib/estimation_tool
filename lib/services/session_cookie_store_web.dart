// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import 'session_cookie_store.dart';

const String _sessionIdKey = 'et_session_id';
const String _userIdKey = 'et_user_id';

SessionCookieStore createCookieStore() => _WebSessionCookieStore();

class _WebSessionCookieStore implements SessionCookieStore {
  @override
  Future<void> clear() async {
    html.document.cookie =
        '$_sessionIdKey=; path=/; max-age=0; SameSite=Lax';
    html.document.cookie =
        '$_userIdKey=; path=/; max-age=0; SameSite=Lax';
  }

  @override
  Future<SessionCookieData?> read() async {
    final cookies = _parseCookies(html.document.cookie ?? '');
    final sessionId = cookies[_sessionIdKey];
    final userId = cookies[_userIdKey];
    if (sessionId == null || sessionId.isEmpty || userId == null || userId.isEmpty) {
      return null;
    }

    return SessionCookieData(sessionId: sessionId, userId: userId);
  }

  @override
  Future<void> write({required String sessionId, required String userId}) async {
    const maxAgeSeconds = 60 * 60 * 24 * 30;
    final encodedSessionId = Uri.encodeComponent(sessionId);
    final encodedUserId = Uri.encodeComponent(userId);

    html.document.cookie =
        '$_sessionIdKey=$encodedSessionId; path=/; max-age=$maxAgeSeconds; SameSite=Lax';
    html.document.cookie =
        '$_userIdKey=$encodedUserId; path=/; max-age=$maxAgeSeconds; SameSite=Lax';
  }

  Map<String, String> _parseCookies(String cookieHeader) {
    final result = <String, String>{};
    for (final cookie in cookieHeader.split(';')) {
      final trimmed = cookie.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      final separator = trimmed.indexOf('=');
      if (separator <= 0) {
        continue;
      }

      final key = trimmed.substring(0, separator).trim();
      final value = trimmed.substring(separator + 1).trim();
      result[key] = Uri.decodeComponent(value);
    }

    return result;
  }
}

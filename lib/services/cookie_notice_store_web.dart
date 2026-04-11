// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import 'cookie_notice_store.dart';

const String _cookieNoticeKey = 'et_cookie_notice_dismissed';

CookieNoticeStore createStore() => _WebCookieNoticeStore();

class _WebCookieNoticeStore implements CookieNoticeStore {
  @override
  Future<void> dismiss() async {
    const maxAgeSeconds = 60 * 60 * 24 * 365;
    html.document.cookie =
        '$_cookieNoticeKey=true; path=/; max-age=$maxAgeSeconds; SameSite=Lax';
  }

  @override
  Future<bool> isDismissed() async {
    final cookies = _parseCookies(html.document.cookie ?? '');
    return cookies[_cookieNoticeKey] == 'true';
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

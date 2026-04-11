import 'cookie_notice_store.dart';

CookieNoticeStore createStore() => _NoopCookieNoticeStore();

class _NoopCookieNoticeStore implements CookieNoticeStore {
  @override
  Future<void> dismiss() async {}

  @override
  Future<bool> isDismissed() async => false;
}

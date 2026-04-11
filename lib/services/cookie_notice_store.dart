import 'cookie_notice_store_stub.dart'
    if (dart.library.html) 'cookie_notice_store_web.dart';

abstract class CookieNoticeStore {
  Future<bool> isDismissed();

  Future<void> dismiss();
}

CookieNoticeStore createCookieNoticeStore() => createStore();

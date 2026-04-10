import 'package:estimation_tool_server/src/session_store.dart';
import 'package:test/test.dart';

void main() {
  group('SessionStore empty session cleanup', () {
    test('expires empty session at 20 minutes', () {
      final store = SessionStore();
      final session = store.createSession(title: 'Planning');
      final sessionId = session['id']! as String;
      final createdAt = DateTime.parse(session['createdAt']! as String).toUtc();

      final expired = store.purgeExpiredEmptySessions(
        nowUtc: createdAt.add(emptySessionTtl),
      );

      expect(expired, contains(sessionId));
      expect(store.getSession(sessionId), isNull);
    });

    test('does not expire empty session before 20 minutes', () {
      final store = SessionStore();
      final session = store.createSession(title: 'Planning');
      final sessionId = session['id']! as String;
      final createdAt = DateTime.parse(session['createdAt']! as String).toUtc();

      final expired = store.purgeExpiredEmptySessions(
        nowUtc: createdAt.add(const Duration(minutes: 19, seconds: 59)),
      );

      expect(expired, isEmpty);
      expect(store.getSession(sessionId), isNotNull);
    });

    test('does not expire session while it has users', () {
      final store = SessionStore();
      final session = store.createSession(title: 'Planning');
      final sessionId = session['id']! as String;
      final createdAt = DateTime.parse(session['createdAt']! as String).toUtc();

      store.addUser(sessionId: sessionId, name: 'Alex');

      final expired = store.purgeExpiredEmptySessions(
        nowUtc: createdAt.add(const Duration(hours: 1)),
      );

      expect(expired, isEmpty);
      expect(store.getSession(sessionId), isNotNull);
    });

    test('starts 20-minute timer when last user leaves', () {
      final store = SessionStore();
      final session = store.createSession(title: 'Planning');
      final sessionId = session['id']! as String;

      final user = store.addUser(sessionId: sessionId, name: 'Alex');
      final userId = user!['id']! as String;

      store.removeUser(sessionId: sessionId, userId: userId);
      final leftAt = DateTime.now().toUtc();

      final notYetExpired = store.purgeExpiredEmptySessions(
        nowUtc: leftAt.add(const Duration(minutes: 19, seconds: 59)),
      );
      expect(notYetExpired, isEmpty);
      expect(store.getSession(sessionId), isNotNull);

      final expired = store.purgeExpiredEmptySessions(
        nowUtc: leftAt.add(emptySessionTtl),
      );
      expect(expired, contains(sessionId));
      expect(store.getSession(sessionId), isNull);
    });
  });
}

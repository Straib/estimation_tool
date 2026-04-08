import 'package:estimation_tool/models/session.dart';
import 'package:estimation_tool/models/user.dart';
import 'package:estimation_tool/models/vote.dart';
import 'package:estimation_tool/services/session_api.dart';

class SessionActionResult<T> {
  const SessionActionResult.success(this.data) : error = null;

  const SessionActionResult.failure(this.error) : data = null;

  final T? data;
  final String? error;

  bool get isSuccess => error == null;
}

class SessionPageService {
  SessionPageService({SessionApi? api}) : _api = api ?? SessionApi();

  final SessionApi _api;

  Future<SessionActionResult<Session>> loadSession(String sessionId) async {
    try {
      final session = await _api.getSession(sessionId);
      return SessionActionResult<Session>.success(session);
    } on SessionApiException catch (error) {
      return SessionActionResult<Session>.failure(error.message);
    } catch (_) {
      return const SessionActionResult<Session>.failure(
        'Could not load session.',
      );
    }
  }

  Future<SessionActionResult<Session>> addUser({
    required String sessionId,
    required String name,
  }) async {
    try {
      await _api.addUser(sessionId: sessionId, name: name);
      final session = await _api.getSession(sessionId);
      return SessionActionResult<Session>.success(session);
    } on SessionApiException catch (error) {
      return SessionActionResult<Session>.failure(error.message);
    } catch (_) {
      return const SessionActionResult<Session>.failure('Could not add user.');
    }
  }

  Future<SessionActionResult<Session>> removeUser({
    required String sessionId,
    required String userId,
  }) async {
    try {
      await _api.removeUser(sessionId: sessionId, userId: userId);
      final session = await _api.getSession(sessionId);
      return SessionActionResult<Session>.success(session);
    } on SessionApiException catch (error) {
      return SessionActionResult<Session>.failure(error.message);
    } catch (_) {
      return const SessionActionResult<Session>.failure(
        'Could not remove user.',
      );
    }
  }

  Future<SessionActionResult<Session>> vote({
    required String sessionId,
    required String userId,
    required StoryPoint storyPoint,
  }) async {
    try {
      await _api.vote(
        sessionId: sessionId,
        userId: userId,
        storyPoint: storyPoint,
      );
      final session = await _api.getSession(sessionId);
      return SessionActionResult<Session>.success(session);
    } on SessionApiException catch (error) {
      return SessionActionResult<Session>.failure(error.message);
    } catch (_) {
      return const SessionActionResult<Session>.failure(
        'Could not submit vote.',
      );
    }
  }

  Future<SessionActionResult<Session>> updateStatus({
    required String sessionId,
    required SessionStatus status,
  }) async {
    try {
      final session = await _api.updateStatus(
        sessionId: sessionId,
        status: status,
      );
      return SessionActionResult<Session>.success(session);
    } on SessionApiException catch (error) {
      return SessionActionResult<Session>.failure(error.message);
    } catch (_) {
      return const SessionActionResult<Session>.failure(
        'Could not update status.',
      );
    }
  }

  Future<SessionActionResult<SessionUserContext>> ensureUser({
    required String sessionId,
    required String name,
  }) async {
    final normalized = name.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const SessionActionResult<SessionUserContext>.failure(
        'Name is required.',
      );
    }

    try {
      var session = await _api.getSession(sessionId);
      User? user = _findUserByName(
        session: session,
        normalizedName: normalized,
      );

      if (user == null) {
        final created = await _api.addUser(
          sessionId: sessionId,
          name: name.trim(),
        );
        session = await _api.getSession(sessionId);
        for (final item in session.users) {
          if (item.id == created.id) {
            user = item;
            break;
          }
        }
      }

      if (user == null) {
        return const SessionActionResult<SessionUserContext>.failure(
          'Could not resolve user.',
        );
      }

      return SessionActionResult<SessionUserContext>.success(
        SessionUserContext(session: session, user: user),
      );
    } on SessionApiException catch (error) {
      return SessionActionResult<SessionUserContext>.failure(error.message);
    } catch (_) {
      return const SessionActionResult<SessionUserContext>.failure(
        'Could not set current user.',
      );
    }
  }

  User? _findUserByName({
    required Session session,
    required String normalizedName,
  }) {
    for (final user in session.users) {
      if (user.name.trim().toLowerCase() == normalizedName) {
        return user;
      }
    }

    return null;
  }
}

class SessionUserContext {
  const SessionUserContext({required this.session, required this.user});

  final Session session;
  final User user;
}

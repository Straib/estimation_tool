import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'src/session_store.dart';
import 'src/session_notifications.dart';

final _notificationManager = SessionNotificationManager();

Future<void> runServer({String host = '0.0.0.0', int port = 8080}) async {
  final store = SessionStore();

  final app = Router()
    ..get('/health', (Request request) {
      return _jsonResponse(HttpStatus.ok, <String, dynamic>{'status': 'ok'});
    })
    ..get('/sessions', (Request request) {
      return _jsonResponse(
        HttpStatus.ok,
        <String, dynamic>{'sessions': store.listSessions()},
      );
    })
    ..post('/sessions', (Request request) async {
      final payload = await _readJsonBody(request);
      final title = (payload['title'] as String?)?.trim();
      if (title == null || title.isEmpty) {
        return _jsonResponse(
          HttpStatus.badRequest,
          <String, dynamic>{'error': 'title is required'},
        );
      }

      final session = store.createSession(title: title);
      return _jsonResponse(HttpStatus.created, <String, dynamic>{'session': session});
    })
    ..get('/sessions/<id>', (Request request, String id) {
      final session = store.getSession(id);
      if (session == null) {
        return _jsonResponse(
          HttpStatus.notFound,
          <String, dynamic>{'error': 'session not found'},
        );
      }

      return _jsonResponse(HttpStatus.ok, <String, dynamic>{'session': session});
    })
    ..delete('/sessions/<id>', (Request request, String id) {
      final removed = store.deleteSession(id);
      if (!removed) {
        return _jsonResponse(
          HttpStatus.notFound,
          <String, dynamic>{'error': 'session not found'},
        );
      }

      return _jsonResponse(HttpStatus.ok, <String, dynamic>{'deleted': true});
    })
    ..post('/sessions/<id>/users', (Request request, String id) async {
      final payload = await _readJsonBody(request);
      final name = (payload['name'] as String?)?.trim();
      if (name == null || name.isEmpty) {
        return _jsonResponse(
          HttpStatus.badRequest,
          <String, dynamic>{'error': 'name is required'},
        );
      }

      final user = store.addUser(
        sessionId: id,
        name: name,
        role: payload['role'] as String?,
        avatarUrl: payload['avatarUrl'] as String?,
      );

      if (user == null) {
        return _jsonResponse(
          HttpStatus.notFound,
          <String, dynamic>{'error': 'session not found'},
        );
      }

      _notificationManager.notifySessionChange(id);
      return _jsonResponse(HttpStatus.created, <String, dynamic>{'user': user});
    })
    ..delete('/sessions/<sessionId>/users/<userId>', (Request request, String sessionId, String userId) {
      final session = store.getSession(sessionId);
      if (session == null) {
        return _jsonResponse(
          HttpStatus.notFound,
          <String, dynamic>{'error': 'session not found'},
        );
      }

      final user = session['users'] as List<dynamic>?;
      if (user == null || !user.any((u) => u['id'] == userId)) {
        return _jsonResponse(
          HttpStatus.badRequest,
          <String, dynamic>{'error': 'user not in session'},
        );
      }

      final updatedSession = store.removeUser(sessionId: sessionId, userId: userId);
      if (updatedSession == null) {
        return _jsonResponse(
          HttpStatus.notFound,
          <String, dynamic>{'error': 'session not found'},
        );
      }

      _notificationManager.notifySessionChange(sessionId);
      return _jsonResponse(HttpStatus.ok, <String, dynamic>{'session': updatedSession});
    })
    ..post('/sessions/<id>/votes', (Request request, String id) async {
      final payload = await _readJsonBody(request);
      final userId = payload['userId'] as String?;
      final storyPoint = payload['storyPoint'] as String?;

      if (userId == null || userId.isEmpty || storyPoint == null || storyPoint.isEmpty) {
        return _jsonResponse(
          HttpStatus.badRequest,
          <String, dynamic>{'error': 'userId and storyPoint are required'},
        );
      }

      final vote = store.addOrUpdateVote(
        sessionId: id,
        userId: userId,
        storyPoint: storyPoint,
      );

      if (vote == VoteWriteResult.sessionNotFound) {
        return _jsonResponse(
          HttpStatus.notFound,
          <String, dynamic>{'error': 'session not found'},
        );
      }

      if (vote == VoteWriteResult.userNotFound) {
        return _jsonResponse(
          HttpStatus.badRequest,
          <String, dynamic>{'error': 'user not in session'},
        );
      }

      if (vote == VoteWriteResult.invalidStoryPoint) {
        return _jsonResponse(
          HttpStatus.badRequest,
          <String, dynamic>{'error': 'invalid storyPoint'},
        );
      }

      _notificationManager.notifySessionChange(id);
      return _jsonResponse(HttpStatus.created, <String, dynamic>{'vote': vote});
    })
    ..post('/sessions/<id>/status', (Request request, String id) async {
      final payload = await _readJsonBody(request);
      final status = payload['status'] as String?;

      if (status == null || status.isEmpty) {
        return _jsonResponse(
          HttpStatus.badRequest,
          <String, dynamic>{'error': 'status is required'},
        );
      }

      final result = store.updateStatus(sessionId: id, statusName: status);
      if (result == StatusWriteResult.sessionNotFound) {
        return _jsonResponse(
          HttpStatus.notFound,
          <String, dynamic>{'error': 'session not found'},
        );
      }

      if (result == StatusWriteResult.invalidStatus) {
        return _jsonResponse(
          HttpStatus.badRequest,
          <String, dynamic>{'error': 'invalid status'},
        );
      }

      _notificationManager.notifySessionChange(id);
      return _jsonResponse(HttpStatus.ok, <String, dynamic>{'session': result});
    });

  var handler = const Pipeline()
      .addMiddleware(_corsMiddleware)
      .addMiddleware(logRequests())
      .addHandler(app.call);

  // Wrap with WebSocket handler
  handler = _createWebSocketMiddleware(handler);

  final server = await shelf_io.serve(handler, host, port);
  print('Session server running at http://${server.address.host}:${server.port}');
}

Future<Map<String, dynamic>> _readJsonBody(Request request) async {
  final body = await request.readAsString();
  if (body.trim().isEmpty) {
    return <String, dynamic>{};
  }

  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Body must be a JSON object.');
  }

  return decoded;
}

Response _jsonResponse(int statusCode, Map<String, dynamic> body) {
  return Response(
    statusCode,
    body: jsonEncode(body),
    headers: <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
    },
  );
}

Middleware get _corsMiddleware {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }

      final response = await innerHandler(request);
      return response.change(headers: <String, String>{...response.headers, ..._corsHeaders});
    };
  };
}

const Map<String, String> _corsHeaders = <String, String>{
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
};

Handler _createWebSocketMiddleware(Handler innerHandler) {
  return (Request request) {
    final requestPath = request.url.path;
    if (requestPath.startsWith('sessions/') && requestPath.endsWith('/ws')) {
      final pathParts = request.url.path.split('/');
      if (pathParts.length == 3) {
        final sessionId = pathParts[1];
        return webSocketHandler(_makeWebSocketHandler(sessionId))(request);
      }
    }
    return innerHandler(request);
  };
}

dynamic _makeWebSocketHandler(String sessionId) {
  return (dynamic webSocket, String? protocol) {
    _notificationManager.addConnection(sessionId, webSocket);
  };
}

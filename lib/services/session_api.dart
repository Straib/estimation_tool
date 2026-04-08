import 'dart:convert';

import 'package:estimation_tool/models/session.dart';
import 'package:estimation_tool/models/user.dart';
import 'package:estimation_tool/models/vote.dart';
import 'package:http/http.dart' as http;

class SessionApiException implements Exception {
  const SessionApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SessionApi {
  SessionApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _baseUri = Uri.parse(
    const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8080',
    ),
  );

  static Uri get baseUri => _baseUri;

  Future<Session> createSession({required String title}) async {
    final payload = <String, dynamic>{'title': title};

    final response = await _client.post(
      _uri('sessions'),
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );

    final json = _decodeObject(response);
    _throwIfError(response, json);

    return Session.fromJson(_readObject(json, 'session'));
  }

  Future<Session> getSession(String sessionId) async {
    final response = await _client.get(_uri('sessions/$sessionId'));
    final json = _decodeObject(response);
    _throwIfError(response, json);

    return Session.fromJson(_readObject(json, 'session'));
  }

  Future<User> addUser({
    required String sessionId,
    required String name,
    String? role,
    String? avatarUrl,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
    };

    final response = await _client.post(
      _uri('sessions/$sessionId/users'),
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );

    final json = _decodeObject(response);
    _throwIfError(response, json);

    return User.fromJson(_readObject(json, 'user'));
  }

  Future<void> removeUser({
    required String sessionId,
    required String userId,
  }) async {
    final response = await _client.delete(
      _uri('sessions/$sessionId/users/$userId'),
    );

    final json = _decodeObject(response);
    _throwIfError(response, json);
  }

  Future<Vote> vote({
    required String sessionId,
    required String userId,
    required StoryPoint storyPoint,
  }) async {
    final payload = <String, dynamic>{
      'userId': userId,
      'storyPoint': storyPoint.label,
    };

    final response = await _client.post(
      _uri('sessions/$sessionId/votes'),
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );

    final json = _decodeObject(response);
    _throwIfError(response, json);

    return Vote.fromJson(_readObject(json, 'vote'));
  }

  Future<Session> updateStatus({
    required String sessionId,
    required SessionStatus status,
  }) async {
    final payload = <String, dynamic>{'status': status.name};

    final response = await _client.post(
      _uri('sessions/$sessionId/status'),
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );

    final json = _decodeObject(response);
    _throwIfError(response, json);

    return Session.fromJson(_readObject(json, 'session'));
  }

  Uri _uri(String path) {
    final basePath = _baseUri.path.endsWith('/')
        ? _baseUri.path.substring(0, _baseUri.path.length - 1)
        : _baseUri.path;
    final normalizedBasePath = basePath.isEmpty ? '' : basePath;
    return _baseUri.replace(path: '$normalizedBasePath/$path');
  }

  static const Map<String, String> _jsonHeaders = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, dynamic> _decodeObject(http.Response response) {
    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const SessionApiException('Invalid response payload.');
  }

  void _throwIfError(http.Response response, Map<String, dynamic> payload) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final message = payload['error'] as String? ?? 'Request failed.';
    throw SessionApiException(message);
  }

  Map<String, dynamic> _readObject(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }

    throw SessionApiException('Missing $key in response.');
  }
}

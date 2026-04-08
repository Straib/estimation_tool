import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class SessionNotificationManager {
  final Map<String, Set<dynamic>> _sessionConnections =
      <String, Set<dynamic>>{};

  void addConnection(String sessionId, dynamic channel) {
    _sessionConnections.putIfAbsent(sessionId, () => <dynamic>{});
    _sessionConnections[sessionId]!.add(channel);

    // Clean up on close - handle both WebSocketChannel and shelf WebSocket types
    try {
      if (channel is WebSocketChannel) {
        channel.stream.listen(
          null,
          onDone: () {
            _sessionConnections[sessionId]?.remove(channel);
            if (_sessionConnections[sessionId]?.isEmpty ?? false) {
              _sessionConnections.remove(sessionId);
            }
          },
          onError: (error) {
            _sessionConnections[sessionId]?.remove(channel);
            if (_sessionConnections[sessionId]?.isEmpty ?? false) {
              _sessionConnections.remove(sessionId);
            }
          },
        );
      }
    } catch (e) {
      // Silent catch - connection type might not support stream
    }
  }

  void notifySessionChange(String sessionId) {
    final connections = _sessionConnections[sessionId];
    if (connections == null) return;

    final message = <String, dynamic>{
      'type': 'session_updated',
      'sessionId': sessionId,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    final messageJson = jsonEncode(message);

    for (final connection in connections.toList()) {
      try {
        if (connection is WebSocketChannel) {
          connection.sink.add(messageJson);
        } else {
          final dynamic sink = connection.sink;
          sink.add(messageJson);
        }
      } catch (e) {
        // Connection broken, will be cleaned up
      }
    }
  }

  int getConnectionCount(String sessionId) {
    return _sessionConnections[sessionId]?.length ?? 0;
  }

  void closeAll(String sessionId) {
    final connections = _sessionConnections[sessionId];
    if (connections != null) {
      for (final connection in connections.toList()) {
        try {
          if (connection is WebSocketChannel) {
            connection.sink.close();
          } else {
            connection?.sink?.close();
          }
        } catch (e) {
          // Ignore close errors
        }
      }
      _sessionConnections.remove(sessionId);
    }
  }
}

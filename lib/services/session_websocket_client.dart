import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef SessionUpdateCallback = void Function();

class SessionWebSocketClient {
  SessionWebSocketClient({required this.sessionId, required this.onSessionUpdate});

  final String sessionId;
  final SessionUpdateCallback onSessionUpdate;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  String? _lastBaseUrl;
  bool _disposed = false;

  Future<void> connect(String baseUrl) async {
    _lastBaseUrl = baseUrl;
    _reconnectTimer?.cancel();

    try {
      final wsUrl = baseUrl
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');
      final url = Uri.parse('$wsUrl/sessions/$sessionId/ws');
      
      _channel = WebSocketChannel.connect(url);
      
      _subscription = _channel!.stream.listen(
        (message) {
          if (message is String) {
            onSessionUpdate();
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _channel = null;
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('WebSocket closed for session $sessionId');
          _channel = null;
          _scheduleReconnect();
        },
      );
    } catch (e) {
      debugPrint('Failed to connect WebSocket: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _lastBaseUrl == null) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      if (_disposed || _lastBaseUrl == null || _channel != null) {
        return;
      }
      connect(_lastBaseUrl!);
    });
  }

  Future<void> disconnect() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    await _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  bool get isConnected => _channel != null;
}

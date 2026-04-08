import 'dart:io';

import 'package:estimation_tool_server/server.dart';

Future<void> main(List<String> arguments) async {
  final host = Platform.environment['HOST'] ?? '0.0.0.0';
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  await runServer(host: host, port: port);
}

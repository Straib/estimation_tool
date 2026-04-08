import 'package:auto_route/auto_route.dart';
import 'package:estimation_tool/pages/create_session_page.dart';
import 'package:estimation_tool/pages/session_page.dart';
import 'package:flutter/material.dart';

part 'routes.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: CreateSessionRoute.page, path: '/', initial: true),
    AutoRoute(page: SessionRoute.page, path: '/session/:sessionId'),
  ];
}

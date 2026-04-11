import 'package:auto_route/auto_route.dart';
import 'package:estimation_tool/pages/create_session_page.dart';
import 'package:estimation_tool/pages/impressum_page.dart';
import 'package:estimation_tool/pages/session_page.dart';
import 'package:flutter/widgets.dart';

part 'routes.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: CreateSessionRoute.page, path: '/', initial: true),
    AutoRoute(page: SessionRoute.page, path: '/session/:sessionId'),
    AutoRoute(page: ImpressumRoute.page, path: '/impressum'),
  ];
}

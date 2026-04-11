// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'routes.dart';

/// generated route for
/// [CreateSessionPage]
class CreateSessionRoute extends PageRouteInfo<void> {
  const CreateSessionRoute({List<PageRouteInfo>? children})
    : super(CreateSessionRoute.name, initialChildren: children);

  static const String name = 'CreateSessionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateSessionPage();
    },
  );
}

/// generated route for
/// [ImpressumPage]
class ImpressumRoute extends PageRouteInfo<void> {
  const ImpressumRoute({List<PageRouteInfo>? children})
    : super(ImpressumRoute.name, initialChildren: children);

  static const String name = 'ImpressumRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ImpressumPage();
    },
  );
}

/// generated route for
/// [SessionPage]
class SessionRoute extends PageRouteInfo<SessionRouteArgs> {
  SessionRoute({
    Key? key,
    required String sessionId,
    List<PageRouteInfo>? children,
  }) : super(
         SessionRoute.name,
         args: SessionRouteArgs(key: key, sessionId: sessionId),
         rawPathParams: {'sessionId': sessionId},
         initialChildren: children,
       );

  static const String name = 'SessionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SessionRouteArgs>(
        orElse:
            () =>
                SessionRouteArgs(sessionId: pathParams.getString('sessionId')),
      );
      return SessionPage(key: args.key, sessionId: args.sessionId);
    },
  );
}

class SessionRouteArgs {
  const SessionRouteArgs({this.key, required this.sessionId});

  final Key? key;

  final String sessionId;

  @override
  String toString() {
    return 'SessionRouteArgs{key: $key, sessionId: $sessionId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SessionRouteArgs) return false;
    return key == other.key && sessionId == other.sessionId;
  }

  @override
  int get hashCode => key.hashCode ^ sessionId.hashCode;
}

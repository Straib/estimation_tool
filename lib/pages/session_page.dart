import 'package:auto_route/auto_route.dart';
import 'package:estimation_tool/components/consensus_display.dart';
import 'package:estimation_tool/components/user_list.dart';
import 'package:estimation_tool/models/session.dart';
import 'package:estimation_tool/models/user.dart';
import 'package:estimation_tool/models/vote.dart';
import 'package:estimation_tool/popups/new_user_popup.dart';
import 'package:estimation_tool/services/session_cookie_store.dart';
import 'package:estimation_tool/services/session_api.dart';
import 'package:estimation_tool/services/session_page_service.dart';
import 'package:estimation_tool/services/session_websocket_client.dart';
import 'package:flutter/material.dart';
import 'package:estimation_tool/components/user_vote_tile.dart';

@RoutePage()
class SessionPage extends StatefulWidget {
  const SessionPage({
    super.key,
    @PathParam('sessionId') required this.sessionId,
  });

  final String sessionId;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final SessionPageService _sessionService = SessionPageService();
  final SessionCookieStore _cookieStore = createSessionCookieStore();
  late final SessionWebSocketClient _wsClient;
  bool _didShowNewUserPopup = false;
  String? _currentUserId;

  Session? _session;
  bool _isLoading = true;
  bool _isMutating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _wsClient = SessionWebSocketClient(
      sessionId: widget.sessionId,
      onSessionUpdate: _onSessionUpdatedRemote,
    );
    _bootstrapSession();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _wsClient.disconnect();
    super.dispose();
  }

  Future<void> _bootstrapSession() async {
    final cookieData = await _cookieStore.read();
    if (cookieData != null && cookieData.sessionId == widget.sessionId) {
      _currentUserId = cookieData.userId;
    }

    await _loadSession();

    if (!mounted || _didShowNewUserPopup || _currentUserId != null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didShowNewUserPopup || _currentUserId != null) {
        return;
      }

      _didShowNewUserPopup = true;
      _openNewUserPopup();
    });
  }

  Future<void> _connectWebSocket() async {
    await _wsClient.connect(SessionApi.baseUri.toString());
  }

  void _onSessionUpdatedRemote() {
    if (!mounted) return;
    _reloadSessionQuietly();
  }

  Future<void> _reloadSessionQuietly() async {
    final result = await _sessionService.loadSession(widget.sessionId);
    if (!mounted) return;

    if (result.isSuccess) {
      final loadedSession = result.data!;
      final activeUserId = _currentUserId;
      if (activeUserId != null) {
        final stillExists = loadedSession.users.any(
          (user) => user.id == activeUserId,
        );
        if (!stillExists) {
          _currentUserId = null;
          await _cookieStore.clear();
        }
      }

      setState(() {
        _session = loadedSession;
      });
    }
  }

  Future<void> _loadSession() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _sessionService.loadSession(widget.sessionId);
    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      final loadedSession = result.data!;
      final activeUserId = _currentUserId;
      if (activeUserId != null) {
        final stillExists = loadedSession.users.any(
          (user) => user.id == activeUserId,
        );
        if (!stillExists) {
          _currentUserId = null;
          await _cookieStore.clear();
        }
      }

      setState(() {
        _session = loadedSession;
      });
    } else {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = result.error;
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyEnsuredUser(SessionUserContext userContext) {
    _cookieStore.write(
      sessionId: widget.sessionId,
      userId: userContext.user.id,
    );
    setState(() {
      _session = userContext.session;
      _currentUserId = userContext.user.id;
    });
  }

  void _openNewUserPopup() {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder:
          (BuildContext context) => NewUserPopup(
            sessionId: widget.sessionId,
            sessionService: _sessionService,
            onEnsured: _applyEnsuredUser,
            onError: (message) {
              if (!mounted) {
                return;
              }

              ScaffoldMessenger.of(
                this.context,
              ).showSnackBar(SnackBar(content: Text(message)));
            },
          ),
    );
  }

  Future<void> _leaveSession() async {
    final currentUserId = _currentUserId;

    setState(() => _isMutating = true);

    if (currentUserId != null) {
      final result = await _sessionService.removeUser(
        sessionId: widget.sessionId,
        userId: currentUserId,
      );

      if (!mounted) {
        return;
      }

      if (!result.isSuccess) {
        setState(() => _isMutating = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error!)));
        return;
      }
    }

    await _cookieStore.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      _currentUserId = null;
      _session = null;
      _isMutating = false;
    });

    context.router.replacePath('/');
  }

  Future<void> _voteForCurrentUser(StoryPoint point) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      return;
    }

    setState(() => _isMutating = true);
    final result = await _sessionService.vote(
      sessionId: widget.sessionId,
      userId: currentUserId,
      storyPoint: point,
    );

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      setState(() {
        _session = result.data;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error!)));
    }

    if (mounted) {
      setState(() => _isMutating = false);
    }
  }

  Future<void> _updateStatus(SessionStatus status) async {
    setState(() => _isMutating = true);
    final result = await _sessionService.updateStatus(
      sessionId: widget.sessionId,
      status: status,
    );

    if (!mounted) {
      return;
    }

    if (status == SessionStatus.voting) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New voting round started.')),
      );
    } else if (status == SessionStatus.revealed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Results revealed.')));
    }

    if (result.isSuccess) {
      setState(() {
        _session = result.data;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error!)));
    }

    if (mounted) {
      setState(() => _isMutating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Session')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadSession,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final session = _session;
    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('Session not available.')),
      );
    }

    User? currentUser;
    if (_currentUserId != null) {
      for (final user in session.users) {
        if (user.id == _currentUserId) {
          currentUser = user;
          break;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Session: ${session.title}'),
        actions: [
          Text('Status: ${session.status.name}'),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed:
                () =>
                    session.status == SessionStatus.revealed
                        ? _updateStatus(SessionStatus.voting)
                        : _updateStatus(SessionStatus.revealed),
            child:
                session.status == SessionStatus.revealed
                    ? const Text('START NEW VOTING')
                    : const Text('REVEAL RESULTS'),
          ),
          const SizedBox(width: 12),

          IconButton(
            onPressed: _leaveSession,
            icon: const Icon(Icons.exit_to_app),
          ),

          const SizedBox(width: 25),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final votePanel = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConsensusDisplay(
                    votes: session.votes,
                    showVotes: session.status == SessionStatus.revealed,
                    userCount: session.users.length,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your vote',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  UserVoteTile(
                    user: currentUser ?? User(id: '', name: 'Unknown'),
                    vote: session.voteForUser(currentUser?.id ?? ''),
                    isDisabled: _isMutating,
                    onVote: _voteForCurrentUser,
                    currentUser: currentUser,
                    isMutating: _isMutating,
                    openNewUserPopup: _openNewUserPopup,
                  ),
                ],
              );

              if (constraints.maxWidth < 900) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    votePanel,
                    const SizedBox(height: 20),
                    UserList(session: session),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: votePanel),
                  const SizedBox(width: 20),
                  Expanded(flex: 1, child: UserList(session: session)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

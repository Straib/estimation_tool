import 'dart:math';

enum SessionStatus { setup, voting, revealed, closed }

const Set<String> _storyPoints = <String>{
  '?',
  '1',
  '2',
  '3',
  '5',
  '8',
  '13',
  '21',
  '☕',
};

class SessionStore {
  final Map<String, _SessionEntity> _sessions = <String, _SessionEntity>{};

  List<Map<String, dynamic>> listSessions() {
    return _sessions.values.map((session) => session.toJson()).toList();
  }

  Map<String, dynamic>? getSession(String sessionId) {
    return _sessions[sessionId]?.toJson();
  }

  Map<String, dynamic> createSession({required String title}) {
    final session = _SessionEntity(
      id: _newId('session'),
      title: title,
      createdAt: DateTime.now().toUtc(),
      status: SessionStatus.setup,
      users: <_UserEntity>[],
      votes: <String, _VoteEntity>{},
    );

    _sessions[session.id] = session;
    return session.toJson();
  }

  bool deleteSession(String sessionId) {
    return _sessions.remove(sessionId) != null;
  }

  Map<String, dynamic>? addUser({
    required String sessionId,
    required String name,
    String? role,
    String? avatarUrl,
  }) {
    final session = _sessions[sessionId];
    if (session == null) {
      return null;
    }

    final user = _UserEntity(
      id: _newId('user'),
      name: name,
      role: role,
      avatarUrl: avatarUrl,
    );

    session.users.add(user);
    return user.toJson();
  }

  Map<String, dynamic>? removeUser({required String sessionId, required String userId}) {
    final session = _sessions[sessionId];
    if (session == null) {
      return null;
    }

    session.users.removeWhere((user) => user.id == userId);
    session.votes.remove(userId);

    return session.toJson();
  }

  Object addOrUpdateVote({
    required String sessionId,
    required String userId,
    required String storyPoint,
  }) {
    final session = _sessions[sessionId];
    if (session == null) {
      return VoteWriteResult.sessionNotFound;
    }

    if (!session.users.any((user) => user.id == userId)) {
      return VoteWriteResult.userNotFound;
    }

    if (!_storyPoints.contains(storyPoint)) {
      return VoteWriteResult.invalidStoryPoint;
    }

    final vote = _VoteEntity(
      userId: userId,
      storyPoint: storyPoint,
      votedAt: DateTime.now().toUtc(),
    );
    session.votes[userId] = vote;

    return vote.toJson();
  }

  Object updateStatus({required String sessionId, required String statusName}) {
    final session = _sessions[sessionId];
    if (session == null) {
      return StatusWriteResult.sessionNotFound;
    }

    final status = SessionStatus.values.where((value) => value.name == statusName);
    if (status.isEmpty) {
      return StatusWriteResult.invalidStatus;
    }

    session.status = status.first;
    return session.toJson();
  }
}

enum VoteWriteResult { sessionNotFound, userNotFound, invalidStoryPoint }

enum StatusWriteResult { sessionNotFound, invalidStatus }

class _SessionEntity {
  _SessionEntity({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.status,
    required this.users,
    required this.votes,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  SessionStatus status;
  final List<_UserEntity> users;
  final Map<String, _VoteEntity> votes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'users': users.map((user) => user.toJson()).toList(),
      'votes': votes.map((key, value) => MapEntry<String, dynamic>(key, value.toJson())),
    };
  }
}

class _UserEntity {
  _UserEntity({required this.id, required this.name, this.role, this.avatarUrl});

  final String id;
  final String name;
  final String? role;
  final String? avatarUrl;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }
}

class _VoteEntity {
  _VoteEntity({required this.userId, required this.storyPoint, required this.votedAt});

  final String userId;
  final String storyPoint;
  final DateTime votedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'storyPoint': storyPoint,
      'votedAt': votedAt.toIso8601String(),
    };
  }
}

final Random _random = Random();

String _newId(String prefix) {
  final now = DateTime.now().microsecondsSinceEpoch;
  final randomPart = _random.nextInt(1 << 32).toRadixString(16);
  return '$prefix-$now-$randomPart';
}

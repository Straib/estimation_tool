import 'package:estimation_tool/models/user.dart';
import 'package:estimation_tool/models/vote.dart';

enum SessionStatus { voting, revealed }

class Session {
	const Session({
		required this.id,
		required this.title,
		required this.createdAt,
		this.status = SessionStatus.voting,
		this.users = const <User>[],
		this.votes = const <String, Vote>{},
	});

	final String id;
	final String title;
	final DateTime createdAt;
	final SessionStatus status;
	final List<User> users;
	final Map<String, Vote> votes;

	Session copyWith({
		String? id,
		String? title,
		DateTime? createdAt,
		SessionStatus? status,
		List<User>? users,
		Map<String, Vote>? votes,
	}) {
		return Session(
			id: id ?? this.id,
			title: title ?? this.title,
			createdAt: createdAt ?? this.createdAt,
			status: status ?? this.status,
			users: users ?? this.users,
			votes: votes ?? this.votes,
		);
	}

	bool get hasVotes => votes.isNotEmpty;

	bool get allUsersVoted {
		if (users.isEmpty) {
			return false;
		}

		return users.every((user) => votes.containsKey(user.id));
	}

	Vote? voteForUser(String userId) => votes[userId];

	Session addUser(User user) {
		return copyWith(users: <User>[...users, user]);
	}

  Session removeUser(String userId) {
    return copyWith(users: users.where((user) => user.id != userId).toList());
  }

	Session addOrUpdateVote(Vote vote) {
		return copyWith(votes: <String, Vote>{...votes, vote.userId: vote});
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'title': title,
			'createdAt': createdAt.toIso8601String(),
			'status': status.name,
			'users': users.map((user) => user.toJson()).toList(),
			'votes': votes.map(
				(key, value) => MapEntry<String, dynamic>(key, value.toJson()),
			),
		};
	}

	factory Session.fromJson(Map<String, dynamic> json) {
		final usersJson = (json['users'] as List<dynamic>? ?? <dynamic>[])
				.cast<Map<String, dynamic>>();
		final votesJson =
				(json['votes'] as Map<String, dynamic>? ?? <String, dynamic>{});

		return Session(
			id: json['id'] as String,
			title: json['title'] as String,
			createdAt: DateTime.parse(json['createdAt'] as String),
			status: SessionStatus.values.firstWhere(
				(sessionStatus) => sessionStatus.name == json['status'],
				orElse: () => SessionStatus.voting,
			),
			users: usersJson.map(User.fromJson).toList(),
			votes: votesJson.map(
				(key, value) => MapEntry(key, Vote.fromJson(value as Map<String, dynamic>)),
			),
		);
	}
}

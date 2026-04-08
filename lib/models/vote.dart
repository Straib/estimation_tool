enum StoryPoint {
	unknown('?'),
	one('1'),
	two('2'),
	three('3'),
	five('5'),
	eight('8'),
	thirteen('13'),
	twentyOne('21'),
	coffee('☕');

	const StoryPoint(this.label);

	final String label;

	static StoryPoint fromLabel(String value) {
		return StoryPoint.values.firstWhere(
			(point) => point.label == value,
			orElse: () => StoryPoint.unknown,
		);
	}
}

class Vote {
	const Vote({
		required this.userId,
		required this.storyPoint,
		required this.votedAt,
	});

	final String userId;
	final StoryPoint storyPoint;
	final DateTime votedAt;

	Vote copyWith({
		String? userId,
		StoryPoint? storyPoint,
		DateTime? votedAt,
	}) {
		return Vote(
			userId: userId ?? this.userId,
			storyPoint: storyPoint ?? this.storyPoint,
			votedAt: votedAt ?? this.votedAt,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'userId': userId,
			'storyPoint': storyPoint.label,
			'votedAt': votedAt.toIso8601String(),
		};
	}

	factory Vote.fromJson(Map<String, dynamic> json) {
		return Vote(
			userId: json['userId'] as String,
			storyPoint: StoryPoint.fromLabel(json['storyPoint'] as String),
			votedAt: DateTime.parse(json['votedAt'] as String),
		);
	}
}

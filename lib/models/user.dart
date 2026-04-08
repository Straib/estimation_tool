class User {
	const User({
		required this.id,
		required this.name,
		this.role,
		this.avatarUrl,
	});

	final String id;
	final String name;
	final String? role;
	final String? avatarUrl;

	User copyWith({
		String? id,
		String? name,
		String? role,
		String? avatarUrl,
	}) {
		return User(
			id: id ?? this.id,
			name: name ?? this.name,
			role: role ?? this.role,
			avatarUrl: avatarUrl ?? this.avatarUrl,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'name': name,
			'role': role,
			'avatarUrl': avatarUrl,
		};
	}

	factory User.fromJson(Map<String, dynamic> json) {
		return User(
			id: json['id'] as String,
			name: json['name'] as String,
			role: json['role'] as String?,
			avatarUrl: json['avatarUrl'] as String?,
		);
	}
}

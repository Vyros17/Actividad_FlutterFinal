class Profile {
  Profile({
    required this.id,
    required this.username,
    required this.createdAt,
  });

  final String id;

  final String username;

  final DateTime createdAt;

  Profile.fromMap(Map<String, dynamic> map)
      : id = map['profile_id'],
        username = map['profile_username'],
        createdAt = DateTime.parse(map['profile_created_at']);
}

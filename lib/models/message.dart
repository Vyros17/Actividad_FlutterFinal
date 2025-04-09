class Message {
  Message({
    required this.id,
    required this.profileId,
    required this.content,
    required this.createdAt,
    required this.isMine,
  });

  final String id;

  final String profileId;

  final String content;

  final DateTime createdAt;

  final bool isMine;

  Message.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : id = map['message_id'],
        profileId = map['message_profile_id'],
        content = map['message_content'],
        createdAt = DateTime.parse(map['message_created_at']),
        isMine = myUserId == map['message_profile_id'];
}

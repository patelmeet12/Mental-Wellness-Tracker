class ChatMessage {
  final String id;
  final String sender; // 'user' or 'coach'
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      sender: json['sender'] as String? ?? 'coach',
      text: json['text'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

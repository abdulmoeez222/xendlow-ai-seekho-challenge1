class Signal {
  final String type;
  final String content;

  Signal({required this.type, required this.content});

  Signal.fromJson(Map<String, dynamic> json)
      : type = json['type'] ?? 'text',
        content = json['content'] ?? '';

  Map<String, dynamic> toJson() => {
        'type': type,
        'content': content,
      };
}

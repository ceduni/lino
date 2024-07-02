class React {
  final String reactIcon;
  final String username;

  React({
    required this.reactIcon,
    required this.username,
  });

  factory React.fromJson(Map<String, dynamic> json) {
    return React(
      reactIcon: json['reactIcon'],
      username: json['username'],
    );
  }
}

class Message {
  final String username;
  final DateTime timestamp;
  final String content;
  final List<React> reactions;
  final String respondsTo;

  Message({
    required this.username,
    required this.timestamp,
    required this.content,
    required this.reactions,
    required this.respondsTo,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    var reactionsList = json['reactions'] as List;
    List<React> reactions = reactionsList.map((i) => React.fromJson(i)).toList();

    return Message(
      username: json['username'],
      timestamp: DateTime.parse(json['timestamp']),
      content: json['content'],
      reactions: reactions,
      respondsTo: json['respondsTo'],
    );
  }
}

class Thread {
  final String bookTitle;
  final String username;
  final String title;
  final DateTime timestamp;
  final List<Message> messages;

  Thread({
    required this.bookTitle,
    required this.username,
    required this.title,
    required this.timestamp,
    required this.messages,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    var messagesList = json['messages'] as List;
    List<Message> messages = messagesList.map((i) => Message.fromJson(i)).toList();

    return Thread(
      bookTitle: json['bookTitle'],
      username: json['username'],
      title: json['title'],
      timestamp: DateTime.parse(json['timestamp']),
      messages: messages,
    );
  }
}
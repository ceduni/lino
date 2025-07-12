class React {
  final String id;
  final String reactIcon;
  final String username;
  final DateTime timestamp;

  React({
    required this.id,
    required this.reactIcon, 
    required this.username,
    required this.timestamp,
  });

  factory React.fromJson(Map<String, dynamic> json) {
    return React(
      id: json['_id'],
      reactIcon: json['reactIcon'],
      username: json['username'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class Message {
  final String id;
  final String username;
  final DateTime timestamp;
  final String content;
  final List<React> reactions;
  final String? respondsTo;

  Message({
    required this.id,
    required this.username,
    required this.timestamp,
    required this.content,
    required this.reactions,
    this.respondsTo,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    var reactionsList = json['reactions'] as List;
    List<React> reactions = reactionsList.map((i) => React.fromJson(i)).toList();

    return Message(
      id: json['_id'],
      username: json['username'],
      timestamp: DateTime.parse(json['timestamp']),
      content: json['content'],
      reactions: reactions,
      respondsTo: json['respondsTo'],
    );
  }
}

class Thread {
  final String id;
  final String bookTitle;
  final String username;
  final String title;
  final String? image;
  final DateTime timestamp;
  final List<Message> messages;

  Thread({
    required this.id,
    required this.bookTitle,
    required this.username,
    required this.title,
    required this.timestamp,
    required this.messages,
    this.image,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    var messagesList = json['messages'] as List;
    List<Message> messages = messagesList.map((i) => Message.fromJson(i)).toList();

    return Thread(
      id: json['_id'],
      bookTitle: json['bookTitle'],
      username: json['username'],
      title: json['title'],
      timestamp: DateTime.parse(json['timestamp']),
      messages: messages,
      image: json['image'],
    );
  }
}
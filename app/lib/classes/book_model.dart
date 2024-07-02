class Book {
  final String? isbn;
  final String qrCodeId;
  final String title;
  final List<String> authors;
  final String? description;
  final String? coverImage;
  final String? publisher;
  final List<String> categories;
  final int? parutionYear;
  final int? pages;
  final List<History> takenHistory;
  final List<History> givenHistory;
  final DateTime dateLastAction;

  Book({
    this.isbn,
    required this.qrCodeId,
    required this.title,
    required this.authors,
    this.description,
    this.coverImage,
    this.publisher,
    required this.categories,
    this.parutionYear,
    this.pages,
    required this.takenHistory,
    required this.givenHistory,
    required this.dateLastAction,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    var authorsList = json['authors'] as List;
    List<String> authors = authorsList.cast<String>();

    var categoriesList = json['categories'] as List;
    List<String> categories = categoriesList.cast<String>();

    var takenHistoryList = json['takenHistory'] as List;
    List<History> takenHistory = takenHistoryList.map((i) => History.fromJson(i)).toList();

    var givenHistoryList = json['givenHistory'] as List;
    List<History> givenHistory = givenHistoryList.map((i) => History.fromJson(i)).toList();

    return Book(
      isbn: json['isbn'],
      qrCodeId: json['qrCodeId'],
      title: json['title'],
      authors: authors,
      description: json['description'],
      coverImage: json['coverImage'],
      publisher: json['publisher'],
      categories: categories,
      parutionYear: json['parutionYear'],
      pages: json['pages'],
      takenHistory: takenHistory,
      givenHistory: givenHistory,
      dateLastAction: DateTime.parse(json['dateLastAction']),
    );
  }
}

class History {
  final String username;
  final DateTime timestamp;

  History({required this.username, required this.timestamp});

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      username: json['username'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
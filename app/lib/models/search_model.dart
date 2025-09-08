class SearchModel<T> {
  final List<T> results;
  final Pagination pagination;

  SearchModel({required this.results, required this.pagination});

  factory SearchModel.fromJson(
    Map<String, dynamic> json,
    String resultType,
    T Function(Map<String, dynamic>) fromJsonConstructor, // Pass the constructor
  ) {
    List<dynamic> results = json[resultType];
    List<T> finalResults = results.map((item) {
      return fromJsonConstructor(item as Map<String, dynamic>);
    }).toList();
    
    return SearchModel(
      results: finalResults,
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}


enum SortOrder {
  asc('asc'),
  desc('desc');

  const SortOrder(this.value);
  final String value;
}


class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalResults;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int limit;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalResults,
    required this.hasNextPage,
    required this.hasPrevPage,
    required this.limit,
  });
  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalResults: json['totalResults'],
      hasNextPage: json['hasNextPage'],
      hasPrevPage: json['hasPrevPage'],
      limit: json['limit'],
    );
  }
}
enum SearchType {
  books(0),
  bookboxes(1);

  const SearchType(this.value);
  final int value;

  static SearchType fromInt(int value) {
    return SearchType.values.firstWhere((type) => type.value == value);
  }
}
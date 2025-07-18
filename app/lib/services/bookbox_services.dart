import 'dart:convert';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/utils/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class BookboxService {
  final String url = baseApiUrl;

  Future<BookBox> getBookBox(String bookBoxId) async {
    final r = await http.get(
      Uri.parse('$url/bookboxes/$bookBoxId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    return BookBox.fromJson(response);
  }
  
  Future<List<BookBox>> searchBookboxes(
      {String? kw,
      bool? asc,
      String? cls,
      num? longitude,
      num? latitude}) async {
    // Make a GET request to the server
    // Send the parameters to the server
    // If the server returns a 200 status code, the bookboxes are found
    // If the server returns another status code, the bookboxes are not found
    var queryParams = {
      if (kw != null) 'kw': kw, // the keywords
      if (asc != null)
        'asc': asc
            .toString(), // the bool to determine if we want the bookboxes in ascending or descending order of the cls
      if (cls != null)
        'cls':
            cls, // the classificator : ['by name', 'by location', 'by number of books']
      if (longitude != null) 'longitude': longitude.toString(),
      if (latitude != null) 'latitude': latitude.toString(),
    };

    final r = await http.get(
      Uri.parse('$url/bookboxes/search').replace(queryParameters: queryParams),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception(response['error']);
    }
    List<BookBox> bookboxes = [];
    for (var bookBoxJson in response['bookboxes']) {
      bookboxes.add(BookBox.fromJson(bookBoxJson));
    }
    return bookboxes;
  }

  Future<void> followBookBox(String token, String bookBoxId) async {
    final r = await http.post(
      Uri.parse('$url/bookboxes/follow/$bookBoxId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    if (r.statusCode != 200) {
      throw Exception(jsonDecode(r.body)['error']);
    }
  }

  Future<void> unfollowBookBox(String token, String bookBoxId) async {
    final r = await http.delete(
      Uri.parse('$url/bookboxes/unfollow/$bookBoxId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    if (r.statusCode != 200) {
      throw Exception(jsonDecode(r.body)['error']);
    }
  }

  Future<List<BookBox>> getFollowedBookboxes(String token, List<String> bookboxIds) async {
    if (bookboxIds.isEmpty) {
      return [];
    }
    
    List<BookBox> followedBookboxes = [];
    
    // Fetch each bookbox individually
    for (String bookboxId in bookboxIds) {
      try {
        final bookbox = await getBookBox(bookboxId);
        followedBookboxes.add(bookbox);
      } catch (e) {
        // Skip bookboxes that can't be fetched (might be deleted)
        print('Error fetching bookbox $bookboxId: $e');
      }
    }
    
    return followedBookboxes;
  }

  Future<bool> isBookboxFollowed(String token, String bookBoxId) async {
    final r = await http.get(
      Uri.parse('$url/bookboxes/is-followed/$bookBoxId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    if (r.statusCode != 200) {
      return false; // If there's an error, assume not followed
    }
    final response = jsonDecode(r.body);
    return response['isFollowed'] ?? false;
  }
}

import 'dart:convert';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/services/user_services.dart';
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
    // Get user
    final user = await UserService().getUser(token);
    return user.followedBookboxes.contains(bookBoxId);
  }
}

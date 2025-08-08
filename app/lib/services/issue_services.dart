import 'dart:convert';

import 'package:Lino_app/models/issue_model.dart';
import 'package:Lino_app/utils/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class IssueServices {
  final String url = baseApiUrl;

  Future<void> reportIssue(String bookboxId, String subject, String description, 
  {String? token, String? email}) async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      if (email != null) 'email': email,
      'bookboxId': bookboxId,
      'subject': subject,
      'description': description,
    });

    final r = await http.post(
      Uri.parse('$url/issues'),
      headers: headers,
      body: body,
    );

    if (r.statusCode != 201) {
      throw Exception(jsonDecode(r.body)['error'] ?? 'Failed to report issue');
    }
  }

  Future<Issue> getIssue(String issueId) async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final r = await http.get(
      Uri.parse('$url/issues/$issueId'),
      headers: headers,
    );

    if (r.statusCode != 200) {
      throw Exception(jsonDecode(r.body)['error'] ?? 'Failed to get issue');
    }

    return Issue.fromJson(jsonDecode(r.body));
  }
}

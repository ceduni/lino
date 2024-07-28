import 'package:flutter/material.dart';

class RequestProvider with ChangeNotifier {
  List<Map<String, dynamic>> _requests = [];

  List<Map<String, dynamic>> get requests => _requests;

  void setRequests(List<Map<String, dynamic>> requests) {
    _requests = requests;
    notifyListeners();
  }

  void addRequest(Map<String, dynamic> request) {
    _requests.insert(0, request);
    notifyListeners();
  }
}

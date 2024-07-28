import 'package:flutter/material.dart';

class ThreadProvider with ChangeNotifier {
  List<Card> _threads = [];

  List<Card> get threads => _threads;

  void setThreads(List<Card> threads) {
    _threads = threads;
    notifyListeners();
  }

  void addThread(Card thread) {
    _threads.insert(0, thread);
    notifyListeners();
  }
}

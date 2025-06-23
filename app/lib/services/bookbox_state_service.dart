import 'package:get/get.dart';

class BookBoxStateService extends GetxController {
  static BookBoxStateService get instance => Get.find();
  
  // Observable to track when a bookbox needs to be refreshed
  final _refreshTrigger = 0.obs;
  
  // Get the current refresh trigger value
  int get refreshTrigger => _refreshTrigger.value;
  
  // Trigger a refresh for all bookbox displays
  void triggerRefresh() {
    _refreshTrigger.value++;
  }
  
  // Listen to refresh triggers
  void listenToRefresh(Function callback) {
    ever(_refreshTrigger, (_) => callback());
  }
}

import 'package:get/get.dart';

class GlobalStateController extends GetxController {
  var currentSelectedBookBox = Rxn<Map<String, dynamic>>();
  
  void setSelectedBookBox(Map<String, dynamic>? bookBox) {
    currentSelectedBookBox.value = bookBox;
  }
  
  Map<String, dynamic>? getSelectedBookBox() {
    return currentSelectedBookBox.value;
  }
}

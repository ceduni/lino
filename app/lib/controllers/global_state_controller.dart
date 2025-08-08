import 'package:Lino_app/models/bookbox_model.dart';
import 'package:get/get.dart';

class GlobalStateController extends GetxController {
  var currentSelectedBookBox = Rxn<BookBox>();

  void setSelectedBookBox(BookBox? bookBox) {
    currentSelectedBookBox.value = bookBox;
  }

  BookBox? getSelectedBookBox() {
    return currentSelectedBookBox.value;
  }
}

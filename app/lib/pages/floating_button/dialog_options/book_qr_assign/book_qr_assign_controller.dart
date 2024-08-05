import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/confirm_book.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:get/get.dart';

class BookQRAssignController extends GetxController {
  var selectedQRCode = ''.obs;
  final BarcodeController barcodeController = Get.find<BarcodeController>();
  final FormController formController = Get.find<FormController>();

  Future<void> submitQRCode() async {
    formController.setSelectedQRCode(barcodeController.barcodeObs.value);
    print('selectedQRCode: ${formController.selectedQRCode.value}');
    print('selectedISBN: ${formController.selectedISBN.value}');
    print('selectedBookBox: ${formController.selectedBookbox.value}');
    Get.delete<BarcodeController>();
    if (formController.selectedISBN.value.isEmpty) {
      formController.submitFormWithoutISBN();
    } else {
      formController.submitFormWithISBN();
    }
  }

  @override
  void onInit() {
    super.onInit();
    ever(barcodeController.barcodeObs, (value) {
      if (value.isNotEmpty &&
          value != 'Unknown Barcode' &&
          value != 'No Barcode Detected') {
        selectedQRCode.value = value;
      }
    });
  }
}

import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:get/get.dart';

class BookQRAssignController extends GetxController {
  // Observable for the selected QR Code
  var selectedQRCode = ''.obs;

  // Reference to BarcodeController and FormController
  final BarcodeController barcodeController = Get.find<BarcodeController>();
  final FormController formController = Get.find<FormController>();

  // Submit the QR Code by setting it in the FormController
  Future<void> submitQRCode() async {
    formController.setSelectedQRCode(barcodeController.barcodeObs.value);

    // Delete the BarcodeController after using it
    Get.delete<BarcodeController>();

    // Check if ISBN is available and submit the form accordingly
    if (formController.selectedISBN.value.isEmpty) {
      formController.submitFormWithoutISBN();
    } else {
      formController.submitFormWithISBN();
    }
  }

  @override
  void onInit() {
    super.onInit();
    // React to changes in the barcode value
    ever(barcodeController.barcodeObs, (value) {
      if (value.isNotEmpty &&
          value != 'Unknown Barcode' &&
          value != 'No Barcode Detected') {
        selectedQRCode.value = value;
      }
    });
  }
}

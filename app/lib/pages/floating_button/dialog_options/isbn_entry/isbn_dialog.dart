import 'package:Lino_app/pages/floating_button/common/build_banner.dart';
import 'package:Lino_app/pages/floating_button/common/build_divider.dart';
import 'package:Lino_app/pages/floating_button/common/build_scanner.dart';
import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/isbn_entry/isbn_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class IsbnDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final barcodeController = Get.put(BarcodeController());
    final isbnController = Get.put(ISBNController());
    final formController = Get.put(FormController());

    return Dialog(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildBanner(context, 'Enter ISBN'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Scan the book's ISBN code"),
                  SizedBox(height: 16.0),
                  buildScanner(barcodeController),
                  SizedBox(height: 16.0),
                  buildCustomDivider(),
                  SizedBox(height: 16.0),
                  _buildISBNTextField(isbnController),
                  SizedBox(height: 16.0),
                  _buildSubmitButton(isbnController, formController),
                  SizedBox(height: 16.0),
                  _buildLoadingOrErrorMessage(isbnController),
                  SizedBox(height: 16.0),
                  _buildExpandButton(formController),
                  SizedBox(height: 16.0),
                  _buildAdditionalFields(formController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildISBNTextField(ISBNController isbnController) {
    return TextField(
      controller: isbnController.textEditingController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'ISBN',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(13),
      ],
    );
  }

  Widget _buildSubmitButton(
      ISBNController isbnController, FormController formController) {
    return Obx(() {
      bool isISBNNotEmpty =
          isbnController.textEditingController.text.isNotEmpty;
      bool isAdditionalFieldsNotEmpty = !formController.isAdditionalFieldsEmpty;

      return ElevatedButton(
        onPressed: isISBNNotEmpty
            ? isbnController.submitISBN
            : (isAdditionalFieldsNotEmpty && !isISBNNotEmpty
                ? isbnController.submitWithoutISBN
                : null),
        style: ElevatedButton.styleFrom(
          foregroundColor: isISBNNotEmpty || isAdditionalFieldsNotEmpty
              ? Colors.blue
              : Colors.grey,
        ),
        child: Text(
          isISBNNotEmpty
              ? 'Submit'
              : (isAdditionalFieldsNotEmpty ? 'Submit without ISBN' : 'Submit'),
        ),
      );
    });
  }

  Widget _buildExpandButton(FormController formController) {
    return ElevatedButton(
      onPressed: formController.toggleExpand,
      child: Text("My book doesn't have ISBN"),
    );
  }

  Widget _buildLoadingOrErrorMessage(ISBNController isbnController) {
    return Obx(() {
      if (isbnController.isLoading.value) {
        return CircularProgressIndicator();
      }
      if (isbnController.errorMessage.isNotEmpty) {
        return Text(
          isbnController.errorMessage.value,
          style: TextStyle(color: Colors.red),
        );
      }
      return SizedBox.shrink();
    });
  }

  Widget _buildAdditionalFields(FormController expandController) {
    return Obx(() {
      if (expandController.isISBNDialogExpanded.value) {
        return Column(
          children: expandController.additionalFieldsForISBN.entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: entry.key,
                      ),
                    ),
                  ))
              .toList(),
        );
      }
      print(
          'expandController.additionalFields: ${expandController.additionalFieldsForISBN}');
      return SizedBox.shrink();
    });
  }
}

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
    final BarcodeController barcodeController = Get.put(BarcodeController());
    final ISBNController isbnController = Get.put(ISBNController());
    final FormController formController = Get.put(FormController());

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
                  Obx(() {
                    return formController.isISBNDialogExpanded.value
                        ? Column(
                      children: [
                        _buildAdditionalFields(formController),
                        const SizedBox(height: 16.0),
                        _buildSubmitWithoutISBNButton(formController),
                      ],
                    )
                        : Column(
                      children: [
                        const Text("Scan the book's ISBN code"),
                        const SizedBox(height: 16.0),
                        buildScanner(barcodeController),
                        const SizedBox(height: 16.0),
                        buildCustomDivider(),
                        const SizedBox(height: 16.0),
                        _buildISBNTextField(isbnController),
                        const SizedBox(height: 16.0),
                        _buildSubmitButton(isbnController),
                        const SizedBox(height: 16.0),
                        _buildLoadingOrErrorMessage(isbnController),
                      ],
                    );
                  }),
                  const SizedBox(height: 16.0),
                  _buildToggleExpandButton(formController),
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
      decoration: const InputDecoration(
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

  Widget _buildSubmitButton(ISBNController isbnController) {
    return Obx(() {
      bool isISBNNotEmpty = isbnController.isbnText.value.isNotEmpty;

      return ElevatedButton(
        onPressed: isISBNNotEmpty ? isbnController.submitISBN : null,
        style: ElevatedButton.styleFrom(
          foregroundColor: isISBNNotEmpty ? Colors.blue : Colors.grey,
        ),
        child: const Text('Submit'),
      );
    });
  }

  Widget _buildSubmitWithoutISBNButton(FormController formController) {
    return Obx(() {
      return ElevatedButton(
        onPressed: formController.submitFormWithoutISBN,
        child: const Text('Submit without ISBN'),
      );
    });
  }

  Widget _buildLoadingOrErrorMessage(ISBNController isbnController) {
    return Obx(() {
      if (isbnController.isLoading.value) {
        return const CircularProgressIndicator();
      }
      if (isbnController.errorMessage.isNotEmpty) {
        return Text(
          isbnController.errorMessage.value,
          style: const TextStyle(color: Colors.red),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildToggleExpandButton(FormController formController) {
    return ElevatedButton(
      onPressed: formController.toggleExpand,
      child: Obx(() {
        return Text(formController.isISBNDialogExpanded.value
            ? "I have an ISBN"
            : "My book doesn't have ISBN");
      }),
    );
  }

  Widget _buildAdditionalFields(FormController formController) {
    return Column(
      children: formController.additionalFieldsForISBN.entries
          .map((entry) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          controller: entry.value,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: entry.key,
          ),
        ),
      ))
          .toList(),
    );
  }
}

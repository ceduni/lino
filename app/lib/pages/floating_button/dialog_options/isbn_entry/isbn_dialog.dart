import 'package:Lino_app/pages/floating_button/common/build_banner.dart';
import 'package:Lino_app/pages/floating_button/common/build_divider.dart';
import 'package:Lino_app/pages/floating_button/common/build_scanner.dart';
import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/isbn_entry/isbn_controller.dart';
import 'package:Lino_app/widgets/image_picker_widget.dart';
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
                        _buildBookTitleDisplay(isbnController),
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
    return Obx(() {
      return TextField(
        controller: isbnController.textEditingController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'ISBN',
          suffixIcon: isbnController.isLoading.value && 
                     isbnController.textEditingController.text.length >= 10
              ? Container(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                )
              : null,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(13),
        ],
      );
    });
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
      final isUploading = formController.isUploadingImage.value;
      return ElevatedButton(
        onPressed: isUploading ? null : formController.submitFormWithoutISBN,
        child: isUploading 
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Uploading...'),
                ],
              )
            : const Text('Submit without ISBN'),
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
      children: [
        // Image picker widget
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Obx(() => ImagePickerWidget(
            onImageSelected: formController.onImageSelected,
            initialImage: formController.selectedCoverImage.value,
            placeholder: 'Add Book Cover Image',
          )),
        ),
        // Text fields
        ...formController.additionalFieldsForISBN.entries
            .map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: entry.value,
            keyboardType: (entry.key == 'Year' || entry.key == 'Pages')
                ? TextInputType.number
                : TextInputType.text,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: entry.key,
            ),
          ),
        ))
            .toList(),
      ],
    );
  }

  Widget _buildBookTitleDisplay(ISBNController isbnController) {
    return Obx(() {
      if (isbnController.bookTitle.value.isNotEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            border: Border.all(color: Colors.green.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Book Found:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isbnController.bookTitle.value + " - " +isbnController.bookAuthor.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}

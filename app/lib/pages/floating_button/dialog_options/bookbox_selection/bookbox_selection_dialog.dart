import 'package:Lino_app/pages/floating_button/common/build_banner.dart';
import 'package:Lino_app/pages/floating_button/common/build_divider.dart';
import 'package:Lino_app/pages/floating_button/common/build_scanner.dart';
import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/bookbox_selection/bookbox_selection_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class BookBoxSelectionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => FormController());
    final BarcodeController barcodeController = Get.put(BarcodeController());
    final BookBoxSelectionController bookboxController =
    Get.put(BookBoxSelectionController());

    return Dialog(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildBanner(context, 'Choose Bookbox'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Scan the bookbox's QR code"),
                  const SizedBox(height: 16.0),
                  buildScanner(barcodeController),
                  const SizedBox(height: 16.0),
                  buildCustomDivider(),
                  const SizedBox(height: 16.0),
                  const Text('Choose from the list'),
                  const SizedBox(height: 16.0),
                  _buildBookBoxDropdown(bookboxController),
                  const SizedBox(height: 16.0),
                  _buildSubmitButton(bookboxController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookBoxDropdown(BookBoxSelectionController bookBoxController) {
    return Obx(() {
      if (bookBoxController.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey[200],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Text('Select a bookbox'),
            value: bookBoxController.selectedBookBox['id'],
            items: bookBoxController.bookBoxes.map((bookBox) {
              final bool knownLocation =
                  bookBoxController.userLocation.value != null;
              final double? distance = knownLocation
                  ? Geolocator.distanceBetween(
                bookBoxController.userLocation.value!.latitude,
                bookBoxController.userLocation.value!.longitude,
                bookBox['location'].latitude,
                bookBox['location'].longitude,
              )
                  : null;
              return DropdownMenuItem<String>(
                value: bookBox['id'],
                child: Container(
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(bookBox['name']),
                    trailing: knownLocation
                        ? Text(
                      '${(distance! / 1000).toStringAsFixed(2)} km',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                    )
                        : null,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              bookBoxController.setSelectedBookBox(value!);
            },
          ),
        );
      }
    });
  }

  Widget _buildSubmitButton(BookBoxSelectionController bookBoxController) {
    return ElevatedButton(
      onPressed: bookBoxController.submitBookBox,
      child: const Text('Submit'),
    );
  }
}

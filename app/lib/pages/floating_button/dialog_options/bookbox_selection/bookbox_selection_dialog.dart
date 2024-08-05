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
    final barcodeController = Get.put(BarcodeController());
    final bookboxController = Get.put(BookBoxSelectionController());

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
                  Text("Scan the bookbox's QR code"),
                  SizedBox(height: 16.0),
                  buildScanner(barcodeController),
                  SizedBox(height: 16.0),
                  buildCustomDivider(),
                  SizedBox(height: 16.0),
                  Text('Choose from the list'),
                  SizedBox(height: 16.0),
                  _buildBookBoxDropdown(bookboxController),
                  SizedBox(height: 16.0),
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
    print('bookboxes: ${bookBoxController.bookBoxes}');
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[200],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text('Select a bookbox'),
          value: bookBoxController.selectedBookBox['id'],
          items: bookBoxController.bookBoxes.map((bookBox) {
            bool knownLocation = bookBoxController.userLocation.value != null;
            var distance = knownLocation
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
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
          onChanged: (value) {
            print('selected bookbox: $value');
            bookBoxController.setSelectedBookBox(value!);
          },
        ),
      );
    });
  }

  Widget _buildSubmitButton(BookBoxSelectionController bookBoxController) {
    return ElevatedButton(
        child: Text('Submit'),
        onPressed: () {
          bookBoxController.submitBookBox();
        });
  }
}

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
  final bool isAddBook;

  const BookBoxSelectionDialog({super.key, required this.isAddBook});

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
                  Obx(() {
                    if (bookboxController.isBookBoxFound.value) {
                      return _buildBookBoxInfo(bookboxController);
                    } else {
                      return Column(
                        children: [
                          if (bookboxController.userLocation.value != null && 
                              bookboxController.nearbyBookBoxes.isNotEmpty)
                            ...[
                              const Text('Nearby Bookboxes'),
                              const Text(
                                'Select from the 5 closest bookboxes to you:',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 16.0),
                              _buildNearbyBookBoxList(bookboxController),
                            ]
                          else if (bookboxController.userLocation.value == null)
                            ...[
                              const Text('Choose from the list'),
                              const Text(
                                'Enable location for smart bookbox selection',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 16.0),
                              _buildBookBoxDropdown(bookboxController),
                            ]
                          else
                            ...[
                              const Text('Choose from the list'),
                              const SizedBox(height: 16.0),
                              _buildBookBoxDropdown(bookboxController),
                            ],
                        ],
                      );
                    }
                  }),
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

  Widget _buildBookBoxInfo(BookBoxSelectionController bookBoxController) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: bookBoxController.isAutoSelected.value 
            ? Colors.green[100] 
            : Colors.grey[200],
        border: bookBoxController.isAutoSelected.value
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Column(
        children: [
          if (bookBoxController.isAutoSelected.value)
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  'Auto-Selected (Nearby)',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          if (bookBoxController.isAutoSelected.value)
            const SizedBox(height: 8.0),
          //Text(
            //'Selected Bookbox: ${bookBoxController.selectedBookBox['name']}',
            //style: TextStyle(fontWeight: FontWeight.w500),
          //),
          const SizedBox(height: 8.0),
          Text('Number of books: ${bookBoxController.selectedBookBox['books'].length}'),
          if (bookBoxController.selectedBookBox['distance'] != null)
            Text(
              'Distance: ${(bookBoxController.selectedBookBox['distance'] as double).toStringAsFixed(1)}m',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          if (bookBoxController.isAutoSelected.value) ...[
            const SizedBox(height: 12.0),
            TextButton(
              onPressed: () {
                bookBoxController.isBookBoxFound.value = false;
                bookBoxController.isAutoSelected.value = false;
                bookBoxController.selectedBookBox.clear();
              },
              child: Text('Choose Different Bookbox'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookBoxDropdown(BookBoxSelectionController bookBoxController) {
    return Obx(() {
      if (bookBoxController.isLoading.value) {
        return const Center(
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
                bookBox['latitude'],
                bookBox['longitude'],
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

  Widget _buildNearbyBookBoxList(BookBoxSelectionController bookBoxController) {
    return Container(
      constraints: BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.grey[100],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: bookBoxController.nearbyBookBoxes.length,
        itemBuilder: (context, index) {
          final bookBox = bookBoxController.nearbyBookBoxes[index];
          final distance = bookBox['distance'] as double? ?? 0.0;
          
          return Card(
            margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              title: Text(
                bookBox['name'],
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '${bookBox['books'].length} books',
                style: TextStyle(fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${distance.toStringAsFixed(0)}m',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: distance <= 50 ? Colors.green : Colors.orange,
                    ),
                  ),
                  if (distance <= 50)
                    Icon(Icons.location_on, size: 16, color: Colors.green),
                ],
              ),
              onTap: () {
                bookBoxController.setSelectedBookBox(bookBox['id']);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton(BookBoxSelectionController bookBoxController) {
    return ElevatedButton(
      onPressed: isAddBook
          ? bookBoxController.submitBookBox
          : bookBoxController.submitBookBox2,
      child: const Text('Submit'),
    );
  }
}

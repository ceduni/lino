import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/book_qr_assign/book_qr_assign_dialog.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/isbn_entry/isbn_dialog.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookBoxSelectionController extends GetxController {
  final selectedBookBox = <String, dynamic>{}.obs;
  final bookBoxes = <Map<String, dynamic>>[].obs;
  final userLocation = Rxn<Position>();
  final isLoading = true.obs;
  final isBookBoxFound = false.obs;
  final BarcodeController barcodeController = Get.find<BarcodeController>();
  final FormController formController = Get.find<FormController>();

  void setSelectedBookBox(String bbid) {
    selectedBookBox.value = bookBoxes
        .firstWhere((element) => element['id'] == bbid, orElse: () => {});
    isBookBoxFound.value = true;
  }

  Future<void> getBookBoxes() async {
    isLoading.value = true;
    try {
      dynamic bbs;
      if (userLocation.value != null) {
        final longitude = userLocation.value?.longitude;
        final latitude = userLocation.value?.latitude;

        bbs = await BookService().searchBookboxes(
          cls: 'by location',
          asc: true,
          longitude: longitude,
          latitude: latitude,
        );
      } else {
        bbs = await BookService().searchBookboxes();
      }

      bookBoxes.value = bbs['bookboxes'].map<Map<String, dynamic>>((bb) {
        return {
          'id': bb['id'],
          'name': bb['name'],
          'infoText': bb['infoText'],
          'location': LatLng(bb['location'][1], bb['location'][0]),
          'books': bb['books']
        };
      }).toList();
    } catch (e) {
      print('Error fetching book boxes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getBookBoxById(String id) async {
    isLoading.value = true;
    try {
      final bookBox = await BookService().getBookBox(id);
      selectedBookBox.value = {
        'id': bookBox['id'],
        'name': bookBox['name'],
        'books': bookBox['books']
      };
      isBookBoxFound.value = true;
    } catch (e) {
      print('Error fetching book box: $e');
      isBookBoxFound.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      }

      userLocation.value = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  void submitBookBox() {
    formController.setSelectedBookBox(selectedBookBox['id']);
    Get.delete<BarcodeController>();
    Get.dialog(NewOrOldBookDialog(selectedBookBox: selectedBookBox['id']));
  }

  void submitBookBox2() {
    formController.setSelectedBookBox(selectedBookBox['id']);
    Get.delete<BarcodeController>();
    Get.dialog(BookQRAssignDialog(
      isAddBook: false,
      formInfo: const {},
      isNewBook: true,
    ));
  }

  @override
  void onInit() {
    super.onInit();
    getUserLocation().then((_) {
      if (userLocation.value != null) {
        getBookBoxes();
      }
    });
    ever(barcodeController.barcodeObs, (String value) async {
      if (value.isNotEmpty &&
          value != 'Unknown Barcode' &&
          value != 'No Barcode Detected') {
        await getBookBoxById(value);
      }
    });
  }
}



class NewOrOldBookDialog extends StatelessWidget {
  final String selectedBookBox;

  const NewOrOldBookDialog({super.key, required this.selectedBookBox});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add a Book'),
      content: Text('Is it a new book or does it already have a QR code?'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
            Get.dialog(IsbnDialog()); // Open ISBNDialog for new books
          },
          child: Text('New Book'),
        ),
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
            Get.dialog(BookQRAssignDialog(isAddBook: true,
              formInfo: {
              'bookBoxId': selectedBookBox,
              },
              isNewBook: false,)); // Open your custom logic for existing books
          },
          child: Text('Already has QR Code'),
        ),
      ],
    );
  }
}

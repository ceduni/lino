import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/book_removal/book_removal_dialog.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/isbn_entry/isbn_dialog.dart';
import 'package:Lino_app/services/bookbox_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class BookBoxSelectionController extends GetxController {
  final selectedBookBox = Rxn<BookBoxWithDistance>();
  final bookBoxes = <BookBoxWithDistance>[].obs;
  final nearbyBookBoxes = <BookBoxWithDistance>[].obs;
  final userLocation = Rxn<Position>();
  final isLoading = true.obs;
  final isBookBoxFound = false.obs;
  final isAutoSelected = false.obs;
  final BarcodeController barcodeController = Get.find<BarcodeController>();
  final FormController formController = Get.find<FormController>();
  
  // Constants for smart selection
  static const double AUTO_SELECT_DISTANCE = 10.0; // meters
  static const int MAX_NEARBY_BOOKBOXES = 5;

  void setSelectedBookBox(String bbid) {
    try {
      selectedBookBox.value = bookBoxes
          .firstWhere((element) => element.id == bbid);
      isBookBoxFound.value = true;
    } catch (e) {
      selectedBookBox.value = null;
      isBookBoxFound.value = false;
    }
  }

  Future<void> getBookBoxes() async {
    isLoading.value = true;
    try {
      List<BookBox> bbs;
      if (userLocation.value != null) {
        final longitude = userLocation.value?.longitude;
        final latitude = userLocation.value?.latitude;

        bbs = await BookboxService().searchBookboxes(
          cls: 'by location',
          asc: true,
          longitude: longitude,
          latitude: latitude,
        );
      } else {
        bbs = await BookboxService().searchBookboxes();
      }

      // Map bookboxes and calculate distances
      List<BookBoxWithDistance> allBookBoxes = bbs.map<BookBoxWithDistance>((bb) {
        double? distance;
        if (userLocation.value != null) {
          distance = Geolocator.distanceBetween(
            userLocation.value!.latitude,
            userLocation.value!.longitude,
            bb.latitude.toDouble(),
            bb.longitude.toDouble(),
          );
        }

        return BookBoxWithDistance(
          id: bb.id,
          name: bb.name,
          infoText: bb.infoText,
          latitude: bb.latitude.toDouble(),
          longitude: bb.longitude.toDouble(),
          books: bb.books,
          distance: distance,
          boroughId: bb.boroughId,
          image: bb.image,
        );
      }).toList();

      bookBoxes.value = allBookBoxes;

      // Smart selection logic
      if (userLocation.value != null) {
        await _performSmartSelection(allBookBoxes);
      }
    } catch (e) {
      print('Error fetching book boxes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _performSmartSelection(List<BookBoxWithDistance> allBookBoxes) async {
    // Sort by distance (closest first)
    allBookBoxes.sort((a, b) {
      final distanceA = a.distance ?? double.infinity;
      final distanceB = b.distance ?? double.infinity;
      return distanceA.compareTo(distanceB);
    });

    // Check if the closest bookbox is within auto-select distance
    if (allBookBoxes.isNotEmpty) {
      final closest = allBookBoxes.first;
      final distance = closest.distance ?? double.infinity;
      
      if (distance <= AUTO_SELECT_DISTANCE) {
        // Auto-select the closest bookbox
        selectedBookBox.value = closest;
        isBookBoxFound.value = true;
        isAutoSelected.value = true;
        
        Get.snackbar(
          'Bookbox Auto-Selected',
          'Found "${closest.name}" ${distance.toStringAsFixed(1)}m away',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        // Show only the top 5 nearest bookboxes
        nearbyBookBoxes.value = allBookBoxes.take(MAX_NEARBY_BOOKBOXES).toList();
        isAutoSelected.value = false;
      }
    }
  }

  Future<void> getBookBoxById(String id) async {
    isLoading.value = true;
    try {
      final bookBox = await BookboxService().getBookBox(id);
      selectedBookBox.value = BookBoxWithDistance(
        id: bookBox.id,
        name: bookBox.name,
        infoText: bookBox.infoText,
        latitude: bookBox.latitude,
        longitude: bookBox.longitude,
        books: bookBox.books,
        boroughId: bookBox.boroughId,
        image: bookBox.image,
        distance: null,
      );
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
    if (selectedBookBox.value != null) {
      formController.setSelectedBookBox(selectedBookBox.value!.id);
      Get.delete<BarcodeController>();
      Get.dialog(IsbnDialog()); // Directly go to ISBN dialog for adding books
    }
  }

  void submitBookBox2() {
    if (selectedBookBox.value == null) return;
    
    // Check if the selected bookbox has books
    final books = selectedBookBox.value!.books;
    
    if (books.isEmpty) {
      Get.snackbar('Info', 'This bookbox has no books to remove',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.delete<BarcodeController>();
    Get.dialog(BookRemovalDialog(
      bookBoxId: selectedBookBox.value!.id,
      books: books,
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

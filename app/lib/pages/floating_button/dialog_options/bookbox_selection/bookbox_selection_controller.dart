import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/isbn_entry/isbn_dialog.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookBoxSelectionController extends GetxController {
  var selectedBookBox = <String, dynamic>{}.obs;
  var bookBoxes = <Map<String, dynamic>>[].obs;
  var userLocation = Rxn<Position>();
  final BarcodeController barcodeController = Get.find<BarcodeController>();
  final FormController formController = Get.find<FormController>();

  void setSelectedBookBox(String bbid) {
    selectedBookBox.value = bookBoxes
        .firstWhere((element) => element['id'] == bbid, orElse: () => {});
  }

  Future<void> getBookBoxes() async {
    try {
      var bbs;
      if (userLocation.value != null) {
        var longitude = userLocation.value?.longitude;
        var latitude = userLocation.value?.latitude;

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
      print(e);
    }
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
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
  }

  void submitBookBox() {
    formController.setSelectedBookBox(selectedBookBox['id']);
    Get.delete<BarcodeController>();
    Get.dialog(IsbnDialog());
  }

  @override
  void onInit() {
    super.onInit();
    getUserLocation().then((_) {
      if (userLocation.value != null) {
        getBookBoxes();
      }
    });
    ever(barcodeController.barcodeObs, (value) {
      if (value.isNotEmpty &&
          value != 'Unknown Barcode' &&
          value != 'No Barcode Detected') {
        setSelectedBookBox(value);
      }
    });
  }
}

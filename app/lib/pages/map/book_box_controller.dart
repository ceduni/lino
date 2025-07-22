import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/models/search_model.dart';
import 'package:Lino_app/services/search_services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapController extends GetxController {
  final Rx<CameraPosition> cameraPosition = CameraPosition(
    target: LatLng(45.500880, -73.615563),
    zoom: 14.0,
  ).obs;

  late GoogleMapController mapController;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void moveToLocation(double latitude, double longitude) {
    final newPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 14.0,
    );
    mapController.animateCamera(CameraUpdate.newCameraPosition(newPosition));
    cameraPosition.value = newPosition;
  }
}

class BookBoxController extends GetxController {
  var bookBoxes = <ShortenedBookBox>[].obs;
  var userLocation = Rxn<Position>();
  var highlightedBookBoxId = RxnString();
  var sortBy = 'by location'.obs;
  var isAscending = true.obs;
  final MapController mapController = Get.put(MapController());

  @override
  void onInit() {
    super.onInit();
    getBookBoxes();
    getUserLocation();
  }

  Future<void> getBookBoxes() async {
    double? longitude = userLocation.value?.longitude;
    double? latitude = userLocation.value?.latitude;

    SearchModel<ShortenedBookBox> response = await SearchService().searchBookboxes(
      cls: sortBy.value,
      asc: isAscending.value ? true : false,
      longitude: sortBy.value == 'by location' ? longitude : null,
      latitude: sortBy.value == 'by location' ? latitude : null,
    );

    List<ShortenedBookBox> bbs = response.results;

    bookBoxes.value = bbs;
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
    await getBookBoxes();
  }

  void highlightBookBox(String bookBoxId) {
    highlightedBookBoxId.value = bookBoxId;
    final index = bookBoxes.indexWhere((bb) => bb.id == bookBoxId);
    if (index != -1) {
      final highlightedBookBox = bookBoxes.removeAt(index);
      bookBoxes.insert(0, highlightedBookBox);
    }
  }
}

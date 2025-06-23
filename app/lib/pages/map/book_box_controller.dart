import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/book_services.dart';


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
  var bookBoxes = <Map<String, dynamic>>[].obs;
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
    var longitude = userLocation.value?.longitude;
    var latitude = userLocation.value?.latitude;

    var bbs = await BookService().searchBookboxes(
      cls: sortBy.value,
      asc: isAscending.value ? true : false,
      longitude: sortBy.value == 'by location' ? longitude : null,
      latitude: sortBy.value == 'by location' ? latitude : null,
    );

    bookBoxes.value = bbs['bookboxes'].map<Map<String, dynamic>>((bb) {
      return {
        'id': bb['id'],
        'name': bb['name'],
        'infoText': bb['infoText'],
        'location': LatLng(bb['location'][1].toDouble(), bb['location'][0].toDouble()),
        'books': bb['books']
      };
    }).toList();
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
    final index = bookBoxes.indexWhere((bb) => bb['id'] == bookBoxId);
    if (index != -1) {
      final highlightedBookBox = bookBoxes.removeAt(index);
      bookBoxes.insert(0, highlightedBookBox);
    }
  }
}


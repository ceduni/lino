// app/lib/vm/home_view_model.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/models/user_model.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/pages/map/book_box_controller.dart';
import 'package:Lino_app/nav_menu.dart';

class HomeViewModel extends ChangeNotifier {
  final BookBoxController _bookBoxController = Get.find<BookBoxController>();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isInitialized = false;
  String? _token;
  User? _userData;
  bool _isLoadingUser = false;
  String? _error;
  int _clickCount = 0;

  bool get isInitialized => _isInitialized;
  String? get token => _token;
  User? get userData => _userData;
  bool get isLoadingUser => _isLoadingUser;
  String? get error => _error;
  BookBoxController get bookBoxController => _bookBoxController;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _isInitialized = true;
      notifyListeners();

      if (_token != null && _token!.isNotEmpty) {
        await loadUserData();
      }
    } catch (e) {
      _error = e.toString();
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> loadUserData() async {
    if (_token == null) return;

    _isLoadingUser = true;
    _error = null;
    notifyListeners();

    try {
      _userData = await UserService().getUser(_token!);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _userData = null;
    }

    _isLoadingUser = false;
    notifyListeners();
  }

  Future<void> checkLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    if (status.isGranted) {
      _bookBoxController.getUserLocation();
    }
  }

  String getSnippet(ShortenedBookBox bbox) {
    if (!bbox.isActive) {
      return 'This book box is currently inactive.';
    }

    if (_bookBoxController.userLocation.value != null) {
      final distance = Geolocator.distanceBetween(
        _bookBoxController.userLocation.value!.latitude,
        _bookBoxController.userLocation.value!.longitude,
        bbox.latitude,
        bbox.longitude,
      ) / 1000;
      return 'Distance: ${distance.toStringAsFixed(2)} km';
    }

    return '${bbox.booksCount} books available';
  }

  List<Marker> getMarkers() {
    final bboxes = _bookBoxController.bookBoxes;

    return bboxes.map((bbox) => Marker(
      markerId: MarkerId(bbox.id),
      position: LatLng(bbox.latitude, bbox.longitude),
      infoWindow: InfoWindow(
        title: bbox.name,
        snippet: getSnippet(bbox),
      ),
      icon: bbox.isActive
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      onTap: () {
        _bookBoxController.highlightBookBox(bbox.id);
      },
    )).toList();
  }

  void navigateToProfile() {
    final NavigationController navController = Get.find<NavigationController>();
    navController.selectedIndex.value = 3; // Profile page
    navController.update();
  }

  Future<void> handleEasterEggClick() async {
    _clickCount++;
    print('Click count: $_clickCount');

    if (_clickCount >= 5) {
      try {
        await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
        _clickCount = 0; // Reset counter after playing sound
        print('Easter egg activated!');
      } catch (e) {
        print('Error playing sound: $e');
      }
    }
  }

  bool get isGuest => _token == null || _token!.isEmpty;
}
// app/lib/vm/favourite_locations_input_view_model.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Lino_app/models/user_model.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouriteLocationsInputViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  final UserService _userService = UserService();

  GoogleMapController? _mapController;
  List<FavouriteLocation> _favouriteLocations = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isAddingLocation = false;

  static const LatLng _defaultLocation = LatLng(45.5017, -73.5673); // Montreal
  LatLng _currentLocation = _defaultLocation;

  // Getters
  GoogleMapController? get mapController => _mapController;
  List<FavouriteLocation> get favouriteLocations => _favouriteLocations;
  Set<Marker> get markers => _markers;
  bool get isLoading => _isLoading;
  bool get isAddingLocation => _isAddingLocation;
  LatLng get currentLocation => _currentLocation;
  String get googleApiKey => dotenv.env['GOOGLE_API_KEY'] ?? '';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    await _getCurrentLocation();
    await _loadFavouriteLocations(token);
    _isLoading = false;
    notifyListeners();
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    try {
      PermissionStatus status = await Permission.locationWhenInUse.status;
      if (status.isDenied) {
        status = await Permission.locationWhenInUse.request();
      }

      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition();
        _currentLocation = LatLng(position.latitude, position.longitude);
        notifyListeners();
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _loadFavouriteLocations(String token) async {
    try {
      final user = await _userService.getUser(token);
      _favouriteLocations = user.favouriteLocations;
      _updateMarkers();
      notifyListeners();
    } catch (e) {
      print('Error loading favourite locations: $e');
    }
  }

  void _updateMarkers() {
    _markers.clear();
    for (int i = 0; i < _favouriteLocations.length; i++) {
      final location = _favouriteLocations[i];
      _markers.add(
        Marker(
          markerId: MarkerId('fav_$i'),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.name,
            snippet: 'Tap to remove',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () => onMarkerTap?.call(location),
        ),
      );
    }
  }

  Function(FavouriteLocation)? onMarkerTap;

  Future<void> onMapTap(LatLng position) async {
    if (_favouriteLocations.length >= 10) {
      showToast('Maximum 10 favourite locations allowed');
      return;
    }

    _isAddingLocation = true;
    notifyListeners();

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String placeName = 'Unknown Location';
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        placeName = _formatPlaceName(placemark);
      }

      await _addFavouriteLocation(position.latitude, position.longitude, placeName);
    } catch (e) {
      showToast('Error adding location: $e');
    } finally {
      _isAddingLocation = false;
      notifyListeners();
    }
  }

  String _formatPlaceName(Placemark placemark) {
    List<String> parts = [];

    if (placemark.name != null && placemark.name!.isNotEmpty) {
      parts.add(placemark.name!);
    }
    if (placemark.street != null && placemark.street!.isNotEmpty && placemark.street != placemark.name) {
      parts.add(placemark.street!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
  }

  Future<void> onPlaceSelected(Prediction prediction) async {
    if (_favouriteLocations.length >= 10) {
      showToast('Maximum 10 favourite locations allowed');
      return;
    }

    _isAddingLocation = true;
    notifyListeners();

    try {
      List<Location> locations = await locationFromAddress(prediction.description!);
      if (locations.isNotEmpty) {
        final location = locations.first;
        await _addFavouriteLocation(
          location.latitude,
          location.longitude,
          prediction.description!,
        );

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)),
        );
      }
    } catch (e) {
      showToast('Error adding location: $e');
    } finally {
      _isAddingLocation = false;
      notifyListeners();
      searchController.clear();
    }
  }

  Future<void> _addFavouriteLocation(double latitude, double longitude, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      await _userService.addUserFavLocation(token, latitude, longitude, name);
      await _loadFavouriteLocations(token);
      showToast('Location added successfully');
    } catch (e) {
      showToast('Error adding location: $e');
    }
  }

  Future<void> removeFavouriteLocation(FavouriteLocation location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      await _userService.deleteUserFavLocation(token, location.name);
      await _loadFavouriteLocations(token);
      showToast('Location removed successfully');
    } catch (e) {
      showToast('Error removing location: $e');
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
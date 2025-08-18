// app/lib/vm/map/map_view_model.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewModel extends ChangeNotifier {
  GoogleMapController? _mapController;
  CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(45.500880, -73.615563), // Montreal coordinates
    zoom: 14.0,
  );

  // Getters
  CameraPosition get cameraPosition => _cameraPosition;
  GoogleMapController? get mapController => _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  Future<void> moveToLocation(double latitude, double longitude, {double zoom = 14.0}) async {
    if (_mapController == null) return;

    final newPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: zoom,
    );

    try {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(newPosition),
      );
      _cameraPosition = newPosition;
      notifyListeners();
    } catch (e) {
      print('Error moving map camera: $e');
    }
  }

  Future<void> moveToBounds(List<LatLng> points) async {
    if (_mapController == null || points.isEmpty) return;

    try {
      // Calculate bounds
      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;

      for (final point in points) {
        minLat = minLat < point.latitude ? minLat : point.latitude;
        maxLat = maxLat > point.latitude ? maxLat : point.latitude;
        minLng = minLng < point.longitude ? minLng : point.longitude;
        maxLng = maxLng > point.longitude ? maxLng : point.longitude;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    } catch (e) {
      print('Error moving map to bounds: $e');
    }
  }

  void updateCameraPosition(CameraPosition position) {
    _cameraPosition = position;
    notifyListeners();
  }
}

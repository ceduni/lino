import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/bookbox_model.dart';

class BookboxMapWidget extends StatefulWidget {
  final List<ShortenedBookBox> bookboxes;
  final Function(List<String>) onSelectionChanged;
  final LatLng? initialLocation;

  const BookboxMapWidget({
    super.key,
    required this.bookboxes,
    required this.onSelectionChanged,
    this.initialLocation,
  });

  @override
  State<BookboxMapWidget> createState() => _BookboxMapWidgetState();
}

class _BookboxMapWidgetState extends State<BookboxMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<String> _selectedBookboxIds = {};
  Position? _userPosition;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _createMarkers();
  }

  @override
  void didUpdateWidget(BookboxMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookboxes != widget.bookboxes) {
      _createMarkers();
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _locationPermissionGranted = true;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _userPosition = position;
      });
      
      // Center map on user location when it becomes available
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
      
      // Recreate markers to update distance information
      _createMarkers();
    } catch (e) {
      developer.log('Error getting location: $e');
    }
  }

  void _createMarkers() {
    Set<Marker> markers = {};

    for (ShortenedBookBox bookbox in widget.bookboxes) {
      bool isSelected = _selectedBookboxIds.contains(bookbox.id);
      
      String snippet = '${bookbox.booksCount} books';
      
      // Add distance to snippet if user location is available
      if (_locationPermissionGranted && _userPosition != null) {
        double distance = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          bookbox.latitude,
          bookbox.longitude,
        );
        
        if (distance < 1000) {
          snippet += ' • ${distance.toStringAsFixed(0)}m away';
        } else {
          snippet += ' • ${(distance / 1000).toStringAsFixed(1)}km away';
        }
      }
      
      markers.add(
        Marker(
          markerId: MarkerId(bookbox.id),
          position: LatLng(bookbox.latitude, bookbox.longitude),
          icon: _getMarkerIcon(bookbox.isActive, isSelected),
          onTap: () => _onMarkerTapped(bookbox),
          infoWindow: InfoWindow(
            title: bookbox.name,
            snippet: snippet,
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  BitmapDescriptor _getMarkerIcon(bool isActive, bool isSelected) {
    if (isSelected) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    } else if (isActive) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else {
      return BitmapDescriptor.defaultMarker; // Gray/default color
    }
  }

  void _onMarkerTapped(ShortenedBookBox bookbox) {
    setState(() {
      if (_selectedBookboxIds.contains(bookbox.id)) {
        _selectedBookboxIds.remove(bookbox.id);
      } else {
        _selectedBookboxIds.add(bookbox.id);
      }
    });

    // Log the updated selection to console
    developer.log('Selected bookbox IDs: ${_selectedBookboxIds.toList()}');
    
    // Notify parent component
    widget.onSelectionChanged(_selectedBookboxIds.toList());
    
    // Recreate markers to update colors
    _createMarkers();
  }

  LatLng _getInitialLocation() {
    // Prioritize user location if available
    if (_locationPermissionGranted && _userPosition != null) {
      return LatLng(_userPosition!.latitude, _userPosition!.longitude);
    }
    
    if (widget.initialLocation != null) {
      return widget.initialLocation!;
    }
    
    if (widget.bookboxes.isNotEmpty) {
      return LatLng(
        widget.bookboxes.first.latitude,
        widget.bookboxes.first.longitude,
      );
    }
    
    // Default to Montreal coordinates if no bookboxes
    return const LatLng(45.5017, -73.5673);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: _getInitialLocation(),
        zoom: 12.0,
      ),
      markers: _markers,
      myLocationEnabled: _locationPermissionGranted,
      myLocationButtonEnabled: _locationPermissionGranted,
      mapType: MapType.normal,
      zoomControlsEnabled: true,
      compassEnabled: true,
    );
  }

  // Public method to get selected bookbox IDs
  List<String> getSelectedBookboxIds() {
    return _selectedBookboxIds.toList();
  }

  // Public method to clear selection
  void clearSelection() {
    setState(() {
      _selectedBookboxIds.clear();
    });
    _createMarkers();
    widget.onSelectionChanged([]);
    developer.log('Selection cleared');
  }

  // Public method to select specific bookboxes
  void selectBookboxes(List<String> ids) {
    setState(() {
      _selectedBookboxIds = Set.from(ids);
    });
    _createMarkers();
    widget.onSelectionChanged(_selectedBookboxIds.toList());
    developer.log('Selected bookbox IDs: ${_selectedBookboxIds.toList()}');
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

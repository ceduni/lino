import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/user_model.dart';
import '../../services/user_services.dart';

class FavouriteLocationsInputPage extends StatefulWidget {
  final String token;
  final SharedPreferences prefs;

  const FavouriteLocationsInputPage({required this.token, required this.prefs, super.key});

  @override
  State<FavouriteLocationsInputPage> createState() => _FavouriteLocationsInputPageState();
}

class _FavouriteLocationsInputPageState extends State<FavouriteLocationsInputPage> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  
  List<FavouriteLocation> _favouriteLocations = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isAddingLocation = false;
  
  static const LatLng _defaultLocation = LatLng(45.5017, -73.5673); // Montreal
  LatLng _currentLocation = _defaultLocation;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _getCurrentLocation();
    await _loadFavouriteLocations();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      PermissionStatus status = await Permission.locationWhenInUse.status;
      if (status.isDenied) {
        status = await Permission.locationWhenInUse.request();
      }
      
      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _loadFavouriteLocations() async {
    try {
      final user = await _userService.getUser(widget.token);
      setState(() {
        _favouriteLocations = user.favouriteLocations;
        _updateMarkers();
      });
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
          onTap: () => _showRemoveLocationDialog(location),
        ),
      );
    }
  }

  Future<void> _onMapTap(LatLng position) async {
    if (_favouriteLocations.length >= 10) {
      _showToast('Maximum 10 favourite locations allowed');
      return;
    }

    setState(() {
      _isAddingLocation = true;
    });

    try {
      // Get place name from coordinates using reverse geocoding
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
      _showToast('Error adding location: $e');
    } finally {
      setState(() {
        _isAddingLocation = false;
      });
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

  Future<void> _onPlaceSelected(Prediction prediction) async {
    if (_favouriteLocations.length >= 10) {
      _showToast('Maximum 10 favourite locations allowed');
      return;
    }

    setState(() {
      _isAddingLocation = true;
    });

    try {
      // Get coordinates from place name
      List<Location> locations = await locationFromAddress(prediction.description!);
      if (locations.isNotEmpty) {
        final location = locations.first;
        await _addFavouriteLocation(
          location.latitude,
          location.longitude,
          prediction.description!,
        );
        
        // Move camera to the selected location
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)),
        );
      }
    } catch (e) {
      _showToast('Error adding location: $e');
    } finally {
      setState(() {
        _isAddingLocation = false;
      });
      _searchController.clear();
    }
  }

  Future<void> _addFavouriteLocation(double latitude, double longitude, String name) async {
    try {
      await _userService.addUserFavLocation(widget.token, latitude, longitude, name);
      await _loadFavouriteLocations();
      _showToast('Location added successfully');
    } catch (e) {
      _showToast('Error adding location: $e');
    }
  }

  Future<void> _removeFavouriteLocation(FavouriteLocation location) async {
    try {
      await _userService.deleteUserFavLocation(widget.token, location.name);
      await _loadFavouriteLocations();
      _showToast('Location removed successfully');
    } catch (e) {
      _showToast('Error removing location: $e');
    }
  }

  void _showRemoveLocationDialog(FavouriteLocation location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Location'),
          content: Text('Remove "${location.name}" from your favourite locations?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeFavouriteLocation(location);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _continue() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4277B8),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: Column(
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Set Your Favourite Locations',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Add places you visit often to get personalized book recommendations',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: GooglePlaceAutoCompleteTextField(
                            textEditingController: _searchController,
                            googleAPIKey: dotenv.env['GOOGLE_API_KEY'] ?? '',
                            inputDecoration: InputDecoration(
                              hintText: 'Search for places...',
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF4277B8)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                            debounceTime: 600,
                            isLatLngRequired: true,
                            getPlaceDetailWithLatLng: (Prediction prediction) {
                              _onPlaceSelected(prediction);
                            },
                            itemClick: (Prediction prediction) {
                              _searchController.text = prediction.description!;
                              _searchController.selection = TextSelection.fromPosition(
                                TextPosition(offset: prediction.description!.length),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Map section
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        children: [
                          GoogleMap(
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                            },
                            initialCameraPosition: CameraPosition(
                              target: _currentLocation,
                              zoom: 12.0,
                            ),
                            markers: _markers,
                            onTap: _onMapTap,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                          ),
                          if (_isAddingLocation)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            ),
                          
                          // Instructions overlay
                          Positioned(
                            top: 10,
                            left: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Tap anywhere on the map to add a location (${_favouriteLocations.length}/10)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom section
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Selected locations count
                        if (_favouriteLocations.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '${_favouriteLocations.length} location${_favouriteLocations.length == 1 ? '' : 's'} added',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Bottom buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _skip,
                              child: const Text(
                                'Skip',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _continue,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF4277B8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

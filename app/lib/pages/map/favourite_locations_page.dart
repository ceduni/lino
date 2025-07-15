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
import '../../utils/constants/colors.dart';

class FavouriteLocationsPage extends StatefulWidget {
  const FavouriteLocationsPage({super.key});

  @override
  State<FavouriteLocationsPage> createState() => _FavouriteLocationsPageState();
}

class _FavouriteLocationsPageState extends State<FavouriteLocationsPage> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();
  
  String? _token;
  List<FavouriteLocation> _favouriteLocations = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isAddingLocation = false;
  
  static const LatLng _defaultLocation = LatLng(45.5017, -73.5673); // Montreal
  LatLng _currentLocation = _defaultLocation;
  
  // Resizable divider state
  double _mapFlex = 2.0;
  double _listFlex = 1.0;
  bool _isDragging = false;
  
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
    await _loadToken();
    await _getCurrentLocation();
    await _loadFavouriteLocations();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
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
    if (_token == null) return;
    
    try {
      final user = await _userService.getUser(_token!);
      setState(() {
        _favouriteLocations = user.favouriteLocations;
        _updateMarkers();
      });
    } catch (e) {
      _showToast('Error loading favourite locations: $e');
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
    if (_token == null) return;

    try {
      await _userService.addUserFavLocation(_token!, latitude, longitude, name);
      await _loadFavouriteLocations();
      _showToast('Location added successfully');
    } catch (e) {
      _showToast('Error adding location: $e');
    }
  }

  Future<void> _removeFavouriteLocation(FavouriteLocation location) async {
    if (_token == null) return;

    try {
      await _userService.deleteUserFavLocation(_token!, location.name);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Locations'),
        backgroundColor: LinoColors.secondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: GooglePlaceAutoCompleteTextField(
                    textEditingController: _searchController,
                    googleAPIKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '',
                    inputDecoration: InputDecoration(
                      hintText: 'Search for places...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
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
                
                // Map
                Expanded(
                  flex: _mapFlex.round(),
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
                    ],
                  ),
                ),
                
                // Resizable divider
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _isDragging = true;
                    });
                  },
                  onPanUpdate: (details) {
                    final RenderBox renderBox = context.findRenderObject() as RenderBox;
                    final screenHeight = renderBox.size.height;
                    final appBarHeight = AppBar().preferredSize.height;
                    final searchBarHeight = 80.0; // Approximate height of search bar
                    final dividerHeight = 20.0;
                    final availableHeight = screenHeight - appBarHeight - searchBarHeight - dividerHeight - MediaQuery.of(context).padding.top;
                    
                    // Calculate drag position relative to the available content area
                    final dragPosition = details.globalPosition.dy - appBarHeight - searchBarHeight - MediaQuery.of(context).padding.top;
                    
                    // Allow very small minimum sizes (5% each) to enable near-complete hiding
                    final minMapHeight = availableHeight * 0.05;
                    final minListHeight = availableHeight * 0.05;
                    
                    // Clamp the drag position to ensure minimums
                    final clampedDragPosition = dragPosition.clamp(minMapHeight, availableHeight - minListHeight);
                    
                    final mapHeight = clampedDragPosition;
                    final listHeight = availableHeight - clampedDragPosition;
                    
                    setState(() {
                      // Use direct proportional flex values for smoother resizing
                      _mapFlex = (mapHeight / availableHeight * 10).clamp(0.5, 9.5);
                      _listFlex = (listHeight / availableHeight * 10).clamp(0.5, 9.5);
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      _isDragging = false;
                    });
                  },
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: _isDragging ? LinoColors.secondary.withOpacity(0.3) : Colors.grey[200],
                      border: Border.symmetric(
                        horizontal: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _isDragging ? LinoColors.secondary : Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Favourite locations list
                Expanded(
                  flex: _listFlex.round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Favourite Locations (${_favouriteLocations.length}/10)',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_favouriteLocations.isNotEmpty)
                                TextButton(
                                  onPressed: _showClearAllDialog,
                                  child: const Text(
                                    'Clear All',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _favouriteLocations.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_off,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No favourite locations yet',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Search for places or tap on the map to add them',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _favouriteLocations.length,
                                  itemBuilder: (context, index) {
                                    final location = _favouriteLocations[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                        ),
                                        title: Text(
                                          location.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _showRemoveLocationDialog(location),
                                        ),
                                        onTap: () {
                                          _mapController?.animateCamera(
                                            CameraUpdate.newLatLng(
                                              LatLng(location.latitude, location.longitude),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to use'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Search for places using the search bar'),
              SizedBox(height: 8),
              Text('• Tap anywhere on the map to add a location'),
              SizedBox(height: 8),
              Text('• Tap on markers to remove locations'),
              SizedBox(height: 8),
              Text('• Drag the divider between map and list to resize'),
              SizedBox(height: 8),
              Text('• Maximum 10 favourite locations allowed'),
              SizedBox(height: 8),
              Text('• Tap on list items to center map on location'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Locations'),
          content: const Text('Are you sure you want to remove all favourite locations?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                for (final location in _favouriteLocations) {
                  await _removeFavouriteLocation(location);
                }
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

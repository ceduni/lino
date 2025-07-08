import 'package:Lino_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import '../bookbox/book_box_screen.dart';
import 'book_box_controller.dart';
import '../../controllers/global_state_controller.dart';

class MapScreen extends HookWidget {
  MapScreen({super.key});
  final GlobalStateController globalState = Get.put(GlobalStateController());
  final BookBoxController bookBoxController = Get.put(BookBoxController());

  Future<void> _checkLocationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    if (status.isGranted) {
      bookBoxController.getUserLocation();
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Location permissions are permanently denied, please enable them in settings.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      _checkLocationPermission(context);
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final selectedBookBox = globalState.currentSelectedBookBox.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Book Boxes'),
              if (selectedBookBox != null)
                Text(
                  'Selected bookbox : ${selectedBookBox['name']}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
            ],
          );
        }),
        actions: [
          Row(
            children: [
              Text('Sort: '),
              PopupMenuButton<String>(
                onSelected: (String value) {
                  switch (value) {
                    case 'nearest first':
                      bookBoxController.sortBy.value = 'by location';
                      bookBoxController.isAscending.value = true;
                    case 'most books first':
                      bookBoxController.sortBy.value = 'by number of books';
                      bookBoxController.isAscending.value = false;
                    case 'by name':
                      bookBoxController.sortBy.value = 'by name';
                      bookBoxController.isAscending.value = true;
                  }
                  bookBoxController.getBookBoxes();
                },
                itemBuilder: (BuildContext context) {
                  return {
                    'nearest first',
                    'most books first',
                    'by name',
                  }.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
                icon: Icon(Icons.sort),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Obx(() {
              final bboxes = bookBoxController.bookBoxes;
              final selectedBookBox = globalState.currentSelectedBookBox.value;
              
              List<Marker> markers = bboxes
                  .map((bbox) {
                    final isSelected = selectedBookBox != null && bbox['id'] == selectedBookBox['id'];
                    
                    return Marker(
                      markerId: MarkerId(bbox['id']),
                      position: LatLng(bbox['latitude'], bbox['longitude']),
                      infoWindow: InfoWindow(
                        title: bbox['name'],
                        snippet: bbox['infoText'],
                      ),
                      icon: isSelected 
                          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
                          : BitmapDescriptor.defaultMarker,
                      onTap: () {
                        bookBoxController.highlightBookBox(bbox['id']);
                      },
                    );
                  })
                  .toList();

              return GoogleMap(
                onMapCreated: bookBoxController.mapController.onMapCreated,
                initialCameraPosition:
                bookBoxController.mapController.cameraPosition.value,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: Set<Marker>.of(markers),
              );
            }),
          ),
          Expanded(
            flex: 1,
            child: Obx(() {
              final bboxes = bookBoxController.bookBoxes;
              final highlightedBookBoxId =
                  bookBoxController.highlightedBookBoxId.value;
              final userLocation = bookBoxController.userLocation.value;

              return ListView.builder(
                itemCount: bboxes.length,
                itemBuilder: (context, index) {
                  final bbox = bboxes[index];
                  double? distance;
                  if (userLocation != null) {
                    distance = Geolocator.distanceBetween(
                      userLocation.latitude,
                      userLocation.longitude,
                      bbox['latitude'],
                      bbox['longitude'],
                    );
                  }

                  return Obx(() {
                    final selectedBookBox = globalState.currentSelectedBookBox.value;
                    final isSelected = selectedBookBox != null && bbox['id'] == selectedBookBox['id'];
                    
                    return Opacity(
                      opacity: highlightedBookBoxId == bbox['id'] ||
                          highlightedBookBoxId == null
                          ? 1.0
                          : 0.5,
                      child: Container(
                        margin:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : LinoColors.secondary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            bbox['name'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (distance != null)
                                Text(
                                  '${(distance / 1000).toStringAsFixed(2)} km away',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              Text(
                                'Books: ${bbox['books'].length}',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) =>
                                    BookBoxScreen(bookBoxId: bbox['id']));
                          },
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

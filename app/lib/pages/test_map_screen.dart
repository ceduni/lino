import 'package:Lino_app/models/bookbox_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TestMapScreen extends StatelessWidget {
  TestMapScreen({super.key, required this.bboxes});
  final List<BookBox> bboxes;

  final MapController mapController = Get.put(MapController());
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            onMapCreated: mapController.onMapCreated,
            initialCameraPosition: mapController.cameraPosition.value,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: bboxes.length,
            itemBuilder: (context, index) {
              final bbox = bboxes[index];
              return ListTile(
                title: Text(bbox.name),
                subtitle: Text(bbox.infoText ?? ''),
                onTap: () {
                  mapController.moveToLocation(
                      bbox.location[0], bbox.location[1]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

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

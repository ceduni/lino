import 'package:Lino_app/common/widgets/book_box_screen/book_box_screen.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// TODO: Rename this class
// TODO: Add navigation button to each book box, it should open a google maps app for navigation
class TestMapScreen extends HookWidget {
  TestMapScreen({super.key});

  final MapController mapController = Get.put(MapController());

  Future<List<Map<String, dynamic>>> getBookBoxList() async {
    var bbs = await BookService().searchBookboxes();

    var returnBBs = bbs['bookboxes'].map<Map<String, dynamic>>((bb) {
      return {
        'id': bb['id'],
        'name': bb['name'],
        'infoText': bb['infoText'],
        'location': LatLng(bb['location'][0], bb['location'][1]),
        'books': bb['books']
      };
    }).toList();
    return returnBBs;
  }

  @override
  Widget build(BuildContext context) {
    final futureBboxes = useMemoized(() => getBookBoxList(), []);
    final bboxesSnapshot = useFuture(futureBboxes);

    if (bboxesSnapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (bboxesSnapshot.hasError) {
      return Center(child: Text('Error: ${bboxesSnapshot.error}'));
    } else if (!bboxesSnapshot.hasData) {
      return Center(child: Text('No data available'));
    }

    final bboxes = bboxesSnapshot.data!;

    List<Marker> markers = bboxes
        .map(
          (bbox) => Marker(
            markerId: MarkerId(bboxes.indexOf(bbox).toString()),
            position: bbox['location'],
            infoWindow: InfoWindow(
              title: bbox['name'],
              snippet: bbox['infoText'],
            ),
          ),
        )
        .toList();

    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            onMapCreated: mapController.onMapCreated,
            initialCameraPosition: mapController.cameraPosition.value,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: Set<Marker>.of(markers),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: bboxes.length,
            itemBuilder: (context, index) {
              final bbox = bboxes[index];
              return GestureDetector(
                // onDoubleTap: () {
                //   mapController.moveToLocation(
                //     bbox['location'].latitude,
                //     bbox['location'].longitude,
                //   );
                // },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookBoxScreen(bookBoxId: bbox['id']),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(bbox['name']),
                  subtitle: Text(bbox['infoText'] ?? ''),
                ),
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

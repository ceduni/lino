import 'package:Lino_app/pages/test_map_screen.dart';
import 'package:Lino_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BookBoxScreen extends StatelessWidget {
  BookBoxScreen({super.key, required this.bookBoxId});

  final String bookBoxId;
  final MapController mapController = Get.put(MapController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Book Boxes'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 30, bottom: 30, left: 90),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 232, 192, 158).withOpacity(0.5),
                ),
                width: double.infinity,
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(child: BookBoxTitleContainer()),
                    const SizedBox(height: 20),
                    Center(
                      child: GoogleMapsContainer(
                        bookBoxLocation: const LatLng(45.5048, -73.5772),
                        mapController: mapController,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: DirectionButton(
                        latitude: 45.0000,
                        longitude: -75.0000,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: BookInBookBoxRow(books: mockBooks),
                    )
                  ],
                )),
              ),
            ),
          ],
        ));
  }
}

class BookBoxTitleContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 251, 251, 240),
            borderRadius: BorderRadius.circular(LinoSizes.borderRadiusLg),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(height: 20), // Add spacing to leave space for the icon
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Book Box Roger Gaudry',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Bottom floor, near the cafeteria'),
                ),
              ),
            ],
          ),
        ),
        Positioned.fromRelativeRect(
          // Adjust this value to control the amount of overflow
          // Get container width and divide by 2 to center the icon
          rect: const RelativeRect.fromLTRB(0, -70, 0, 0),

          child: Icon(
            Icons.home,
            size: 60,
            color: Color.fromARGB(255, 142, 199, 233),
          ),
        ),
      ],
    );
  }
}

class GoogleMapsContainer extends StatelessWidget {
  const GoogleMapsContainer(
      {super.key, required this.bookBoxLocation, required this.mapController});
  final MapController mapController;
  final LatLng bookBoxLocation;

  @override
  Widget build(BuildContext context) {
    var cameraPosition = CameraPosition(
      target: bookBoxLocation,
      zoom: 15,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(LinoSizes.borderRadiusLg),
      child: Container(
        height: 300,
        width: double.infinity,
        child: GoogleMap(
          onMapCreated: mapController.onMapCreated,
          initialCameraPosition: cameraPosition,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: <Marker>{
            Marker(markerId: MarkerId('1'), position: bookBoxLocation),
          },
        ),
      ),
    );
  }
}

final List<Map<String, String>> mockBooks = [
  {
    'coverUrl': 'https://placehold.co/50x80.png',
    'title': 'Book 1',
  },
  {
    'coverUrl': 'https://placehold.co/50x80.png',
    'title': 'Book 2',
  },
  {
    'coverUrl': 'https://placehold.co/50x80.png',
    'title': 'Book 3',
  },
  {
    'coverUrl': 'https://placehold.co/50x80.png',
    'title': 'Book 4',
  },
  {
    'coverUrl': 'https://placehold.co/50x80.png',
    'title': 'Book 5',
  },
];

class DirectionButton extends StatelessWidget {
  final double latitude;
  final double longitude;

  const DirectionButton(
      {super.key, required this.longitude, required this.latitude});

  Future<void> _openGoogleMapsApp(double latitude, double longitude) async {
    // TODO: Get book box latlng
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';

    if (await canLaunchUrlString(googleMapsUrl)) {
      await launchUrlString(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LinoSizes.borderRadiusLg),
        color: Color.fromARGB(255, 142, 199, 233),
      ),
      child: TextButton(
        onPressed: () {
          _openGoogleMapsApp(longitude, latitude);
        },
        child: const Text('Direction to Book Box'),
      ),
    );
  }
}

class BookInBookBoxRow extends StatelessWidget {
  final List<Map<String, String>> books;

  const BookInBookBoxRow({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(
            12), // Replace with your border radius constant
        color: Color.fromARGB(255, 242, 226, 196),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: books.map((book) => _buildBookItem(book)).toList(),
        ),
      ),
    );
  }

  Widget _buildBookItem(Map<String, String> book) {
    return Container(
      width: 50, // Adjust the width and height as necessary
      height: 80,
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(book['coverUrl']!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

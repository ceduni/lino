import 'package:Lino_app/pages/book_details_page.dart';
import 'package:Lino_app/pages/test_map_screen.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:Lino_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class BookBoxScreen extends HookWidget {
  BookBoxScreen({super.key, required this.bookBoxId});

  final String bookBoxId;
  final MapController mapController = Get.put(MapController());

  Future<Map<String, dynamic>> getBookBoxData(String bookBoxId) async {
    var bb = await BookService().getBookBox(bookBoxId);
    return {
      'name': bb['name'],
      'infoText': bb['infoText'],
      'location': LatLng(bb['location'][0], bb['location'][1]),
      'books': bb['books']
    };
  }

  @override
  Widget build(BuildContext context) {
    final bookBoxData =
        useFuture(useMemoized(() => getBookBoxData(bookBoxId), [bookBoxId]));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Boxes'),
      ),
      body: bookBoxData.connectionState == ConnectionState.waiting
          ? Center(child: CircularProgressIndicator())
          : bookBoxData.hasError
              ? Center(child: Text('Error loading data'))
              : buildContent(context, bookBoxData.data!),
    );
  }

  Widget buildContent(BuildContext context, Map<String, dynamic> data) {
    final bbName = data['name'];
    final bbInfoText = data['infoText'];
    final bbLocation = data['location'];
    final bbBooks = data['books'];
    return Column(
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
                  Center(
                    child: BookBoxTitleContainer(
                      name: bbName,
                      infoText: bbInfoText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GoogleMapsContainer(
                      bookBoxLocation: bbLocation,
                      mapController: mapController,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: DirectionButton(
                      bookBoxLocation: bbLocation,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: BookInBookBoxRow(
                      books: (bbBooks as List<dynamic>)
                          .map((item) => item as Map<String, dynamic>)
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BookBoxTitleContainer extends StatelessWidget {
  final String name;
  final String infoText;

  const BookBoxTitleContainer(
      {super.key, required this.name, required this.infoText});

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
            children: [
              SizedBox(height: 20), // Add spacing to leave space for the icon
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      infoText,
                    )),
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

class DirectionButton extends StatelessWidget {
  final LatLng bookBoxLocation;

  const DirectionButton({super.key, required this.bookBoxLocation});

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
          double latitude = bookBoxLocation.latitude;
          double longitude = bookBoxLocation.longitude;
          _openGoogleMapsApp(longitude, latitude);
        },
        child: const Text('Direction to Book Box'),
      ),
    );
  }
}

class BookInBookBoxRow extends StatelessWidget {
  final List<Map<String, dynamic>> books;

  BookInBookBoxRow({super.key, required this.books});

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
          children: books.map((book) => _buildBookItem(context, book)).toList(),
        ),
      ),
    );
  }

  Widget _buildBookItem(BuildContext context, Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsPage(book: book),
          ),
        );
      },
      child: Container(
        width: 100, // Adjust the width and height as necessary
        height: 160,
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(book['coverImage']!),
            // image: NetworkImage(
            //     'http://books.google.com/books/content?id=O_ZvDwAAQBAJ&printsec=frontcover&img=1'),
            // image: NetworkImage(
            //     'https://placehold.co/100x160.png'), // Path to a placeholder image in your assets
            fit: BoxFit.cover,
            // Adding error handling
            onError: (Object exception, StackTrace? stackTrace) {
              DecorationImage(
                image: NetworkImage(
                    'https://placehold.co/100x160.png'), // Path to a placeholder image in your assets
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      ),
    );
  }
}

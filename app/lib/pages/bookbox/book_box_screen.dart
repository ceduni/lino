import 'package:Lino_app/services/book_services.dart';
import 'package:Lino_app/services/bookbox_state_service.dart';
import 'package:Lino_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../controllers/global_state_controller.dart';

import 'book_in_bookbox_row.dart';

class BookBoxScreen extends StatefulWidget {
  const BookBoxScreen({super.key, required this.bookBoxId});

  final String bookBoxId;

  @override
  State<BookBoxScreen> createState() => _BookBoxScreenState();
}

class _BookBoxScreenState extends State<BookBoxScreen> {
  final BookBoxStateService _stateService = Get.find<BookBoxStateService>();
  Future<Map<String, dynamic>>? _bookBoxDataFuture;

  @override
  void initState() {
    super.initState();
    _loadBookBoxData();
    
    // Listen for refresh triggers
    _stateService.listenToRefresh(() {
      if (mounted) {
        _loadBookBoxData();
      }
    });
  }

  void _loadBookBoxData() {
    setState(() {
      _bookBoxDataFuture = _getBookBoxData(widget.bookBoxId);
    });
  }

  Future<Map<String, dynamic>> _getBookBoxData(String bookBoxId) async {
    var bb = await BookService().getBookBox(bookBoxId);
    return {
      'name': bb['name'],
      'image': bb['image'],
      'infoText': bb['infoText'],
      'location': LatLng(bb['latitude'].toDouble(), bb['longitude'].toDouble()),
      'books': bb['books']
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _bookBoxDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }
          return buildContent(context, snapshot.data!);
        },
      ),
    );
  }

  Widget buildContent(BuildContext context, Map<String, dynamic> data) {
    final bbName = data['name'];
    final bbImage = data['image'];
    final bbInfoText = data['infoText'];
    final bbLocation = data['location'];
    final bbBooks = data['books'];
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Center(
                    child: BookBoxTitleContainer(
                      bbName: bbName,
                      bbInfoText: bbInfoText,
                      bbImageLink: bbImage,
                      bbLocation: bbLocation,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: DirectionButton(bookBoxLocation: bbLocation),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: SelectBookBoxButton(
                      bookBoxData: {
                        'id': widget.bookBoxId,
                        'name': bbName,
                        'latitude': bbLocation.latitude,
                        'longitude': bbLocation.longitude,
                        'infoText': bbInfoText,
                        'image': bbImage,
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: BookInBookBoxRow(
                      books: (bbBooks as List<dynamic>).map((item) => item as Map<String, dynamic>).toList(),
                      bbid: widget.bookBoxId,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}

class BookBoxTitleContainer extends StatelessWidget {
  final String bbName;
  final String bbInfoText;
  final String bbImageLink;
  final LatLng bbLocation;

  const BookBoxTitleContainer({super.key, required this.bbName, required this.bbInfoText, required this.bbImageLink, required this.bbLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(250, 250, 240, 1).withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: Image.network(bbImageLink).image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          bbName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Where can you find the bookbox: $bbInfoText',
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Kanit',
          ),
        ),
      ]),
    );
  }
}

class DirectionButton extends StatelessWidget {
  final LatLng bookBoxLocation;

  const DirectionButton({super.key, required this.bookBoxLocation});

  Future<void> _openGoogleMapsApp(double latitude, double longitude) async {
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0.5,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          double latitude = bookBoxLocation.latitude;
          double longitude = bookBoxLocation.longitude;
          _openGoogleMapsApp(longitude, latitude);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.directions, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Get Directions',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectBookBoxButton extends StatelessWidget {
  final Map<String, dynamic> bookBoxData;

  const SelectBookBoxButton({super.key, required this.bookBoxData});

  @override
  Widget build(BuildContext context) {
    final GlobalStateController globalState = Get.put(GlobalStateController());
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LinoSizes.borderRadiusLg),
        color: Colors.green.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0.5,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          globalState.setSelectedBookBox(bookBoxData);
          
          // Show a confirmation snackbar
          Get.snackbar(
            'BookBox Updated',
            'Selected "${bookBoxData['name']}" as your current bookbox',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
          
          // Close the dialog
          Navigator.of(context).pop();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Select BookBox',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

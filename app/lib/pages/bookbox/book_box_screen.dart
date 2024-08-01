import 'package:Lino_app/services/book_services.dart';
import 'package:Lino_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'book_in_bookbox_row.dart';

class BookBoxScreen extends HookWidget {
  BookBoxScreen({super.key, required this.bookBoxId});

  final String bookBoxId;

  Future<Map<String, dynamic>> getBookBoxData(String bookBoxId) async {
    var bb = await BookService().getBookBox(bookBoxId);
    return {
      'name': bb['name'],
      'image': bb['image'],
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
      backgroundColor: Colors.transparent,
      body: bookBoxData.connectionState == ConnectionState.waiting
          ? Center(child: CircularProgressIndicator())
          : bookBoxData.hasError
              ? Center(child: Text('Error loading data'))
              : RefreshIndicator(
                  onRefresh: () => getBookBoxData(bookBoxId),
                  child: buildContent(context, bookBoxData.data!),
                ),
    );
  }

  Widget buildContent(BuildContext context, Map<String, dynamic> data) {
    final bbName = data['name'];
    final bbImage = data['image'];
    final bbInfoText = data['infoText'];
    final bbLocation = data['location'];
    final bbBooks = data['books'];
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 232, 192, 158).withOpacity(0.5),
            ),
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
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
                    child: BookInBookBoxRow(
                      books: (bbBooks as List<dynamic>)
                          .map((item) => item as Map<String, dynamic>)
                          .toList(),
                      bbid: bookBoxId,
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
  final String bbName;
  final String bbInfoText;
  final String bbImageLink;
  final LatLng bbLocation;

  const BookBoxTitleContainer(
      {super.key,
      required this.bbName,
      required this.bbInfoText,
      required this.bbImageLink,
      required this.bbLocation});

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
          width: 400,
          height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 1.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: Image.network(bbImageLink).image,
                fit: BoxFit.cover,
              )),
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

import 'package:Lino_app/models/bookbox_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Lino_app/services/book_services.dart';
import '../bookbox/book_box_screen.dart'; 

class BookBoxesList extends StatelessWidget {
  final String query;

  const BookBoxesList({required this.query});

  Future<Position> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  double _calculateDistance(Position userLocation, double bookboxLatitude, double bookboxLongitude) {
    return Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      bookboxLatitude,
      bookboxLongitude,
    ) / 1000; // Convert to kilometers
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookBox>>(
      future: BookService().searchBookboxes(kw: query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No bookboxes found.'));
        }

        final bookboxes = snapshot.data!;
        return FutureBuilder<Position>(
          future: _getUserLocation(),
          builder: (context, locationSnapshot) {
            if (locationSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (locationSnapshot.hasError) {
              return Center(child: Text('Error: ${locationSnapshot.error}'));
            } else if (!locationSnapshot.hasData) {
              return Center(child: Text('Unable to get location.'));
            }

            final userLocation = locationSnapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: bookboxes.length,
              itemBuilder: (context, index) {
                final bookbox = bookboxes[index];
                final distance = _calculateDistance(userLocation, bookbox.latitude, bookbox.longitude);
                final distanceStr = '${distance.toStringAsFixed(2)} km';
                return Card(
                    color: Colors.blueGrey[50],
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: Image.network(
                        bookbox.image ?? '',
                        fit: BoxFit.cover,
                        width: 50,
                        height: 75,
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          return Icon(Icons.book);
                        },
                      ),
                      title: Text(
                        bookbox.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${bookbox.books.length} books',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      trailing: Text(distanceStr),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookBoxScreen(bookBoxId: bookbox.id),
                          ),
                        );
                      },
                    )
                );
              },
            );
          },
        );
      },
    );
  }
}

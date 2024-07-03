import 'package:Lino_app/widgets/bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Lino_app/widgets/search_app_bar.dart';
import 'package:Lino_app/widgets/floating_menu.dart';

class BookBoxLocationList extends StatefulWidget {
  final List<BookBox> bookBoxes;

  BookBoxLocationList({required this.bookBoxes});

  @override
  _BookBoxLocationListState createState() => _BookBoxLocationListState();
}

class _BookBoxLocationListState extends State<BookBoxLocationList> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        onUserIconPressed: () {
          // Handle user icon press
        },
        onMenuPressed: () {
          // Handle hamburger menu press
        },
        onSearchChanged: (value) {
          // Handle search input change
        },
      ),
      body: Column(
        children: [
          Container(
            // decoration: const BoxDecoration(
            //   color: Colors.red,
            //   borderRadius: BorderRadius.only(
            //     bottomLeft: Radius.circular(100),
            //     bottomRight: Radius.circular(100),
            //   ),
            // ),
            height: 300,
            // width: 300,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.bookBoxes.length,
              itemBuilder: (context, index) {
                return BookBoxListItem(bookBox: widget.bookBoxes[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(),
    );
  }
}

class BookBoxListItem extends StatelessWidget {
  final BookBox bookBox;

  BookBoxListItem({required this.bookBox});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 202, 214, 236),
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Image.asset(
          'assets/logo_without_bird.png',
          width: 50,
          height: 100,
        ),
        title: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookBox.infoText.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 5),
              Text(
                bookBox.books.toString() ?? 'No books',
                style: TextStyle(fontSize: 16),
              )
            ],
          ),
        ),
      ),
    );
  }
}

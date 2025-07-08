import 'package:flutter/material.dart';
import 'package:Lino_app/services/book_services.dart';
import 'book_details_page.dart';
import 'package:Lino_app/pages/map/map_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../controllers/global_state_controller.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final bookService = BookService();
  final GlobalStateController globalState = Get.put(GlobalStateController());

  List<Map<String, dynamic>> bookBoxes = [];
  bool isLoading = true;
  String? error;
  bool isGridMode = false; // Track if we are in grid mode
  Position? userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadBookBoxes();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      userLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      
      // pour forcer le reload
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error getting user location: $e');
    }
  }

  String _getClosestSync() {
    if (bookBoxes.isEmpty) {
      return 'Loading bookboxes...';
    }

    if (userLocation == null) {
      return 'Getting location...';
    }

    // closest bb
    Map<String, dynamic>? closestBookBox;
    double minDistance = double.infinity;

    for (var bookBox in bookBoxes) {
      if (bookBox['latitude'] != null && bookBox['longitude'] != null) {
        double distance = Geolocator.distanceBetween(
          userLocation!.latitude,
          userLocation!.longitude,
          bookBox['latitude'].toDouble(),
          bookBox['longitude'].toDouble(),
        );

        if (distance < minDistance) {
          minDistance = distance;
          closestBookBox = bookBox;
        }
      }
    }

    if (closestBookBox != null) {
      double distanceInKm = minDistance / 1000;
      globalState.setSelectedBookBox(closestBookBox);
      return '${closestBookBox['name']} (${distanceInKm.toStringAsFixed(1)}km)';

    }

    return bookBoxes.first['name'] ?? 'Unknown';
  }

  Future<void> _loadBookBoxes() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await bookService.searchBookboxes();
      setState(() {
        bookBoxes = List<Map<String, dynamic>>.from(
          data['bookboxes'].map((bookbox) => bookbox),
        );
        isLoading = false;
      });
      
      
      if (userLocation == null) {
        await Future.delayed(Duration(milliseconds: 500));
        if (mounted) {
          setState(() {}); 
        }
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _toggleViewMode() {
    setState(() {
      isGridMode = !isGridMode; // Toggle between grid and horizontal mode
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books Overview'),
        actions: [
          IconButton(
            icon: Icon(isGridMode ? Icons.view_list : Icons.view_module),
            onPressed: _toggleViewMode,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(),
                ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
              Text(
                _getClosestSync(),
                style: TextStyle(fontSize: 16),
              ),
              Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),
        ),
        
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : RefreshIndicator(
        onRefresh: _loadBookBoxes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              for (var bb in bookBoxes) ...[
                Container(
                  width: double.infinity,
                  height: 32,
                  margin: const EdgeInsets.only(bottom: 0),
                  color: Color.fromRGBO(125, 201, 236, 1),
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bookbox ${bb['name']}',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(3, 51, 86, 1),
                    ),
                  ),
                ),
                Container(
                  color: Color.fromRGBO(250, 250, 240, 1),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: isGridMode
                      ? _buildGridBooks(bb['books']) // Grid view mode
                      : _buildHorizontalBooks(bb['books']), // Horizontal scroll mode
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Horizontal book list (default)
  Widget _buildHorizontalBooks(List books) {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (context, index) {
          var book = books[index];
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => BookDetailsPage(
                  book: book,
                  bbid: "null",
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: book['coverImage'] != null
                  ? Image.network(
                      book['coverImage']!,
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        return _errorImage(book['title']);
                      },
                    )
                  : _errorImage(book['title']),
            ),
          );
        },
      ),
    );
  }

  // Grid book list
  Widget _buildGridBooks(List books) {
    double bookWidth = 100; // Fixed width for the book covers

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // Disable GridView scrolling, rely on outer ScrollView
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width ~/ bookWidth, // Calculate books per row
        childAspectRatio: 0.7, // Adjust aspect ratio to fit book covers
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        var book = books[index];
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => BookDetailsPage(
                book: book,
                bbid: "null",
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: book['coverImage'] != null
                ? Image.network(
                    book['coverImage']!,
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return _errorImage(book['title']);
                    },
                  )
                : _errorImage(book['title']),
          ),
        );
      },
    );
  }

  Widget _errorImage(String title) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 100),
      child: Container(
        color: Colors.grey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
    );
  }

}

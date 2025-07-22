import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/models/search_model.dart';
import 'package:Lino_app/services/bookbox_services.dart';
import 'package:Lino_app/services/search_services.dart';
import 'package:flutter/material.dart';
import 'book_details_page.dart';
// import 'package:Lino_app/pages/map/map_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../controllers/global_state_controller.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final GlobalStateController globalState = Get.put(GlobalStateController());

  List<ShortenedBookBox> bookBoxes = [];
  bool isLoading = true;
  String? error;
  bool isGridMode = false; // Track if we are in grid mode
  Position? userLocation;
  
  // Track expanded bookboxes and their loaded books
  Map<String, bool> expandedBookBoxes = {};
  Map<String, List<Book>> loadedBooks = {};
  Map<String, bool> loadingBooks = {};

  @override
  void initState() {
    super.initState();
    // _getUserLocation();
    _loadBookBoxes();
    
    
    globalState.currentSelectedBookBox.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // Future<void> _getUserLocation() async {
  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       return;
  //     }

  //     var permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         return;
  //       }
  //     }

  //     if (permission == LocationPermission.deniedForever) {
  //       return;
  //     }

  //     userLocation = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
      
  //     // Initialize closest bookbox selection after the build is complete
  //     //WidgetsBinding.instance.addPostFrameCallback((_) {
  //       //_setClosestBookBoxIfNone();
  //     //});
      
  //     // pour forcer le reload
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   } catch (e) {
  //     print('Error getting user location: $e');
  //   }
  // }

  // void _setClosestBookBoxIfNone() {
  //   if (bookBoxes.isEmpty || userLocation == null) {
  //     return;
  //   }

  //   // Only set if no bookbox is currently selected
  //   if (globalState.currentSelectedBookBox.value != null) {
  //     return;
  //   }

  //   // Find the closest bookbox
  //   BookBox? closestBookBox;
  //   double minDistance = double.infinity;

  //   for (var bookBox in bookBoxes) {
  //     double distance = Geolocator.distanceBetween(
  //       userLocation!.latitude,
  //       userLocation!.longitude,
  //       bookBox.latitude,
  //       bookBox.longitude,
  //     );

  //     if (distance < minDistance) {
  //       minDistance = distance;
  //       closestBookBox = bookBox;
  //     }
  //       }

  //   if (closestBookBox != null) {
  //     globalState.setSelectedBookBox(closestBookBox);
  //     // Trigger a rebuild to update the display text
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   }
  // }

  // String _getDisplayText() {
  //   if (bookBoxes.isEmpty) {
  //     return 'Loading bookboxes...';
  //   }

  //   if (userLocation == null) {
  //     return 'Getting location...';
  //   }

  //   final currentSelected = globalState.currentSelectedBookBox.value;
  //   if (currentSelected != null) {
  //     return currentSelected.name;
  //   }

  //   return 'Select a bookbox';
  // }

  Future<void> _loadBookBoxes() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      SearchModel<ShortenedBookBox> data = await SearchService().searchBookboxes();
      setState(() {
        bookBoxes = data.results;
        isLoading = false;
      });
      
      // 
      //WidgetsBinding.instance.addPostFrameCallback((_) {
        // _setClosestBookBoxIfNone();
      //});
      
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

  Future<void> _toggleBookBoxExpansion(String bookBoxId) async {
    setState(() {
      expandedBookBoxes[bookBoxId] = !(expandedBookBoxes[bookBoxId] ?? false);
    });

    // If expanding and books not loaded yet, load them
    if (expandedBookBoxes[bookBoxId] == true && !loadedBooks.containsKey(bookBoxId)) {
      await _loadBooksForBookBox(bookBoxId);
    }
  }

  Future<void> _loadBooksForBookBox(String bookBoxId) async {
    setState(() {
      loadingBooks[bookBoxId] = true;
    });

    try {
      final bookBox = await BookboxService().getBookBox(bookBoxId);
      setState(() {
        loadedBooks[bookBoxId] = bookBox.books;
        loadingBooks[bookBoxId] = false;
      });
    } catch (e) {
      setState(() {
        loadingBooks[bookBoxId] = false;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading books: $e')),
      );
    }
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
        /* 
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
                      _getDisplayText(),
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),
        ),*/
        
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
                GestureDetector(
                  onTap: () => _toggleBookBoxExpansion(bb.id),
                  child: Container(
                    width: double.infinity,
                    height: 32,
                    margin: const EdgeInsets.only(bottom: 0),
                    color: Color.fromRGBO(125, 201, 236, 1),
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Bookbox ${bb.name} (${bb.booksCount} books)',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(3, 51, 86, 1),
                            ),
                          ),
                        ),
                        Icon(
                          expandedBookBoxes[bb.id] == true 
                            ? Icons.expand_less 
                            : Icons.expand_more,
                          color: const Color.fromRGBO(3, 51, 86, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                if (expandedBookBoxes[bb.id] == true) ...[
                  Container(
                    color: Color.fromRGBO(250, 250, 240, 1),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: _buildBookBoxContent(bb.id),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Horizontal book list (default)
  Widget _buildHorizontalBooks(List<Book> books) {
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
                  bbid: 'null',
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: book.coverImage != null
                  ? Image.network(
                      book.coverImage!,
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        return _errorImage(book.title);
                      },
                    )
                  : _errorImage(book.title),
            ),
          );
        },
      ),
    );
  }

  // Grid book list
  Widget _buildGridBooks(List<Book> books) {
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
            child: book.coverImage != null
                ? Image.network(
                    book.coverImage!,
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return _errorImage(book.title);
                    },
                  )
                : _errorImage(book.title),
          ),
        );
      },
    );
  }

  Widget _buildBookBoxContent(String bookBoxId) {
    // Show loading indicator while books are being loaded
    if (loadingBooks[bookBoxId] == true) {
      return Container(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Get the loaded books for this bookbox
    final books = loadedBooks[bookBoxId];
    
    // If no books loaded or empty list
    if (books == null || books.isEmpty) {
      return Container(
        height: 100,
        child: Center(
          child: Text(
            'No books available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    // Display books based on current view mode
    return isGridMode
        ? _buildGridBooks(books)
        : _buildHorizontalBooks(books);
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

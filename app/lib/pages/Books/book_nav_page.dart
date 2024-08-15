import 'package:Lino_app/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'book_details_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final bookService = BookService();
  final userService = UserService();

  List<Map<String, dynamic>> bookBoxes = [];
  bool isLoading = true;
  String? error;
  bool isGridMode = false; // Track if we are in grid mode

  @override
  void initState() {
    super.initState();
    _loadBookBoxes();
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
              FutureBuilder<bool>(
                future: _isValidUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || !snapshot.data!) {
                    return SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 50,
                        color: Color.fromRGBO(239, 175, 132, 1),
                        padding: const EdgeInsets.symmetric(vertical: 7.0),
                        child: Text(
                          'Liked books',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(3, 51, 86, 1),
                          ),
                        ),
                      ),
                      FavoriteBooksSection(),
                    ],
                  );
                },
              ),
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
              child: Image.network(
                book['coverImage'],
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return _errorImage(book['title']);
                },
              ),
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
            child: Image.network(
              book['coverImage'],
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return _errorImage(book['title']);
              },
            ),
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

  Future<bool> _isValidUser() async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    if (token == null) {
      return false;
    }
    try {
      var user = await userService.getUser(token);
      return user['user'] != null;
    } catch (e) {
      return false;
    }
  }
}

class FavoriteBooksSection extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final token = useState<String?>(null);

    useEffect(() {
      SharedPreferences.getInstance().then((prefs) {
        token.value = prefs.getString('token');
      });
      return null;
    }, []);

    final favoriteBooksFuture =
    useFuture(useMemoized(() => getUserFavoriteBooks(token.value), [token.value]));

    if (favoriteBooksFuture.connectionState != ConnectionState.done) {
      return Center(child: CircularProgressIndicator());
    }

    if (favoriteBooksFuture.hasError || favoriteBooksFuture.data == null) {
      return Center(child: Text('Error loading favorite books or favorite books data is null'));
    }

    final favoriteBooks = favoriteBooksFuture.data!;

    return Container(
      color: Color.fromRGBO(250, 250, 240, 1),
      height: 250,
      child: favoriteBooks.isEmpty
          ? Center(
        child: Text(
          'None are available yet',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      )
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: favoriteBooks.length,
        itemBuilder: (context, index) {
          var book = favoriteBooks[index];
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
              child: Image.network(
                book['coverImage'],
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 100),
                    child: Container(
                      color: Colors.grey,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            book['title'],
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                            maxLines: null,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getUserFavoriteBooks(String? token) async {
    if (token == null) {
      return [];
    }
    try {
      Map<String, dynamic> userData = await UserService().getUser(token);
      List<dynamic> favoriteBookIds = userData['user']['favoriteBooks'];
      List<Map<String, dynamic>> favoriteBooks = await Future.wait(
        favoriteBookIds.map((id) => BookService().getBook(id)).toList(),
      );
      return favoriteBooks;
    } catch (e) {
      print('Error fetching favorite books: $e');
      return [];
    }
  }
}

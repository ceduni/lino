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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        for (var bb in bookBoxes) ...[
                          Container(
                            width: double.infinity,
                            height: 50,
                            color: Color.fromRGBO(125, 201, 236, 1),
                            padding: const EdgeInsets.symmetric(vertical: 7.0),
                            child: Text(
                              bb['name'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(3, 51, 86, 1),
                              ),
                            ),
                          ),
                          Container(
                            color: Color.fromRGBO(250, 250, 240, 1),
                            child: Container(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: bb['books'].length,
                                itemBuilder: (context, index) {
                                  var book = bb['books'][index];
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => BookDetailsPage(
                                          book: book,
                                          bbid: bb['id'],
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.network(
                                        book['coverImage'],
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return ConstrainedBox(
                                            constraints: BoxConstraints(
                                                maxWidth: 100),
                                            child: Container(
                                              color: Colors.grey,
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    book['title'],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: null,
                                                    overflow:
                                                        TextOverflow.visible,
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
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
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
        useFuture(useMemoized(() => getUserFavoriteBooks(token.value!), [token.value]));

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
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
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
      // Fetch user data
      Map<String, dynamic> userData = await UserService().getUser(token);

      // Extract favorite book IDs
      List<dynamic> favoriteBookIds = userData['user']['favoriteBooks'];

      // Fetch favorite books details
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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import '../../services/book_services.dart';
import '../../services/thread_services.dart';
import '../../services/user_services.dart';

class BookDetailsPage extends StatefulWidget {
  final Map<String, dynamic> book;
  final String bbid;

  BookDetailsPage({required this.book, required this.bbid});

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final user = await UserService().getUser(token);
      final favs = user['user']['favoriteBooks'];
      if (user['user'] != null && user['user'].isEmpty) {
        return;
      }
      setState(() {
        _isFavorite = favs.contains(widget.book['_id']);
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        if (_isFavorite) {
          await UserService().removeFromFavorites(token, widget.book['_id']);
          setState(() {
            _isFavorite = false;
          });
        } else {
          await UserService().addToFavorites(token, widget.book['_id']);
          setState(() {
            _isFavorite = true;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<bool> _isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    if (token == null) {
      return false;
    }

    var user = await UserService().getUser(token);

    // Check if the 'user' key is an empty object
    if (user['user'] != null && user['user'].isEmpty) {
      return false;
    }

    return true;
  }

  void _showAddThreadForm(BuildContext context, String bookId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddThreadForm(bookId: bookId),
    );
  }

  void _showGetBookConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Get book "${widget.book['title']}" from this bookbox?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                _getBookFromBookBox();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getBookFromBookBox() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      await BookService().getBookFromBB(widget.book['qrCodeId'], widget.bbid, token: token);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book retrieved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container for the book cover, title, and author
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(250, 250, 240, 1).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.network(
                        widget.book['coverImage'],
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          return Container(
                            width: 150,
                            height: 200,
                            color: Colors.grey,
                            child: Center(
                              child: Text(widget.book['title'], style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(widget.book['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Authors: ${widget.book['authors'].join(', ')}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    FutureBuilder<bool>(
                      future: _isUserLoggedIn(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return SizedBox.shrink(); // Show nothing while waiting
                        } else if (snapshot.hasData && snapshot.data == true) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700, // Semi-dark green background
                                ),
                                onPressed: () {
                                  _showAddThreadForm(context, widget.book['_id']);
                                },
                                child: Text('+ Add Thread', style: TextStyle(color: Colors.white)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: LinoColors.secondary, // LinoColors.primary background
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Rectangular shape with rounded corners
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Increase horizontal padding
                                ),
                                onPressed: _isLoading ? null : _toggleFavorite,
                                child: Icon(
                                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return SizedBox.shrink(); // Show nothing if no token
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Container for the book description and other details
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(244, 226, 193, 1).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Kanit')),
                    SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(250, 250, 240, 1).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: ExpandableText(widget.book['description']),
                    ),
                    SizedBox(height: 16),
                    Text('ISBN: ${widget.book['isbn']}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Publisher: ${widget.book['publisher']}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Categories: ${widget.book['categories'].join(', ')}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Year: ${widget.book['parutionYear']}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Pages: ${widget.book['pages']}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                        ),
                        onPressed: _showGetBookConfirmation,
                        child: Text('Get book from bookbox'),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;

  ExpandableText(this.text);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  late String firstHalf;
  late String secondHalf;

  bool flag = true;
  int FIRST_HALF_CHARACTERS = 200;

  @override
  void initState() {
    super.initState();

    if (widget.text.length > FIRST_HALF_CHARACTERS) {
      firstHalf = widget.text.substring(0, FIRST_HALF_CHARACTERS);
      secondHalf = widget.text.substring(FIRST_HALF_CHARACTERS, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: secondHalf.isEmpty
          ? Text(
        firstHalf,
        textAlign: TextAlign.start,
        style: TextStyle(fontFamily: 'Kanit'),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            flag ? (firstHalf + "...") : (firstHalf + secondHalf),
            textAlign: TextAlign.start,
            style: TextStyle(fontFamily: 'Kanit'),
          ),
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(
                  flag ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                  color: Colors.blue,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                flag = !flag;
              });
            },
          ),
        ],
      ),
    );
  }
}

class AddThreadForm extends StatefulWidget {
  final String bookId;

  const AddThreadForm({required this.bookId, Key? key}) : super(key: key);

  @override
  _AddThreadFormState createState() => _AddThreadFormState();
}

class _AddThreadFormState extends State<AddThreadForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          await ThreadService().createThread(token, widget.bookId, _titleController.text);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Thread created successfully!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create New Thread', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'The title of your new thread',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

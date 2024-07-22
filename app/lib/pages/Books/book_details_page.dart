import 'package:flutter/material.dart';

class BookDetailsPage extends StatelessWidget {
  final Map<String, dynamic> book;

  BookDetailsPage({required this.book});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Set the dialog background to transparent
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add some padding for better layout
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
            children: [
              // Container for the book cover, title, and author
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(250, 250, 240, 1).withOpacity(0.9), // White background with opacity
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.network(book['coverImage']),
                    ),
                    SizedBox(height: 8), // Add some space between elements
                    Text(book['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Authors: ${book['authors'].join(', ')}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                  ],
                ),
              ),
              SizedBox(height: 16), // Add some space between the two containers

              // Container for the book description and other details
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(244, 226, 193, 1).withOpacity(0.9), // White background with opacity
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(250, 250, 240, 1).withOpacity(0.9), // White background with opacity
                        borderRadius: BorderRadius.circular(5), // Rounded corners
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: ExpandableText(book['description']),
                    ),
                    SizedBox(height: 16),
                    Text('ISBN: ${book['isbn']}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Publisher: ${book['publisher']}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Categories: ${book['categories'].join(', ')}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Year: ${book['parutionYear']}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Pages: ${book['pages']}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
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
      padding: const EdgeInsets.all(8.0), // Add padding for the text
      child: secondHalf.isEmpty
          ? Text(
              firstHalf,
              textAlign: TextAlign.center, // Center-align the text
              style: TextStyle(fontFamily: 'Kanit'), // Apply the font
            )
          : Column(
              children: <Widget>[
                Text(
                  flag ? (firstHalf + "...") : (firstHalf + secondHalf),
                  textAlign: TextAlign.center, // Center-align the text
                  style: TextStyle(fontFamily: 'Kanit'), // Apply the font
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

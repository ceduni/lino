import 'package:flutter/material.dart';

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
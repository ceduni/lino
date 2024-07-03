import 'package:flutter/material.dart';

class FloatingMenu extends StatefulWidget {
  @override
  _FloatingMenuState createState() => _FloatingMenuState();
}

class _FloatingMenuState extends State<FloatingMenu> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'btn1',
                    onPressed: () {},
                    tooltip: 'Button 1',
                    child: Icon(Icons.new_label),
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'btn2',
                    onPressed: () {},
                    tooltip: 'Button 2',
                    child: Icon(Icons.label_off),
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'btn3',
                    onPressed: () {},
                    tooltip: 'Button 3',
                    child: Icon(Icons.note_add),
                  ),
                ],
              ),
            ),
          FloatingActionButton(
            onPressed: _toggleExpand,
            tooltip: 'Expand',
            child: Icon(_isExpanded ? Icons.close : Icons.add),
          ),
        ],
      ),
    );
  }
}

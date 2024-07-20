import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTile extends StatefulWidget {
  final Map<String, dynamic> message;
  final List<dynamic> allMessages;
  final void Function(String, bool) onReact; // Update the callback to include reaction handling
  final void Function(String, Map<String, dynamic>) onReply;

  MessageTile({required this.message, required this.allMessages, required this.onReact, required this.onReply}); // Update constructor

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool _isHovered = false;

  int countReactions(String reactionType) {
    return widget.message['reactions'].where((reaction) => reaction['reactIcon'] == reactionType).length;
  }

  @override
  Widget build(BuildContext context) {
    final String respondsToId = widget.message['respondsTo'];
    final respondingToMessage = widget.allMessages.firstWhere((msg) => msg['_id'] == respondsToId, orElse: () => null);
    final DateTime timestamp = DateTime.parse(widget.message['timestamp']);
    final String formattedDate = DateFormat('MM/dd/yyyy hh:mm a').format(timestamp);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _isHovered = true;
        });
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (respondingToMessage != null)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0)),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${respondingToMessage['username']}: ',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.3)),
                          ),
                          TextSpan(
                            text: respondingToMessage['content'],
                            style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black.withOpacity(0.3)),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  margin: respondingToMessage == null ? EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0)
                      : EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 15.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.amber[100], // Light beige color
                    borderRadius: respondingToMessage == null ? BorderRadius.circular(16.0)
                        : BorderRadius.only(
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.message['username'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8.0), // Space between username and date
                          Text(
                            formattedDate,
                            style: TextStyle(fontSize: 12.0, color: Colors.grey), // Smaller font size for the date
                          ),
                        ],
                      ),
                      SizedBox(height: 4.0),
                      Text(widget.message['content']),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.thumb_up),
                            onPressed: () => widget.onReact(widget.message['_id'], true),
                          ),
                          Text('${countReactions('good')}'),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.thumb_down),
                            onPressed: () => widget.onReact(widget.message['_id'], false),
                          ),
                          Text('${countReactions('bad')}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isHovered)
              Positioned(
                right: 80, // Adjust this value to position closer to the message container
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.reply),
                    onPressed: () {
                      widget.onReply(widget.message['_id'], widget.message);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

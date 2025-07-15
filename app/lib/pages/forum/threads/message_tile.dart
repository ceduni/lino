import 'package:Lino_app/models/thread_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTile extends StatefulWidget {
  final Message message;
  final List<Message> allMessages;
  final void Function(String, bool) onReact;
  final void Function(String, Message) onReply;
  final Color backgroundColor;
  final String? currentUsername;

  MessageTile({
    required this.message,
    required this.allMessages,
    required this.onReact,
    required this.onReply,
    required this.backgroundColor,
    this.currentUsername,
  });

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool _isHovered = false;

  int countReactions(String reactionType) {
    return widget.message.reactions.where((reaction) => reaction.reactIcon == reactionType).length;
  }

  bool userHasReacted(String reactionType) {
    if (widget.currentUsername == null) return false;
    return widget.message.reactions.any((reaction) => reaction.reactIcon == reactionType && reaction.username == widget.currentUsername);
  }

  @override
  Widget build(BuildContext context) {
    final String? respondsToId = widget.message.respondsTo;
    Message? respondingToMessage;
    
    if (respondsToId != null) {
      try {
        respondingToMessage = widget.allMessages.firstWhere((msg) => msg.id == respondsToId);
      } catch (e) {
        respondingToMessage = null;
      }
    }
    
    final DateTime timestamp = DateTime.parse(widget.message.timestamp.toIso8601String());
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 1),
                        ),
                      ],
                      color: Color(0x71737373),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0)),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${respondingToMessage.username}: ',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withValues(alpha: 0.55)),
                          ),
                          TextSpan(
                            text: respondingToMessage.content,
                            style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black.withValues(alpha: 0.55)),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                    color: widget.backgroundColor,
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
                          Expanded(
                            child: Text(
                              widget.message.username,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            formattedDate,
                            style: TextStyle(fontSize: 12.0, color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.0),
                      Text(widget.message.content),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up,
                              color: userHasReacted('good')
                                  ? Color(0xFF4CAF50)
                                  : Color(0xFFD3D3D3),
                              shadows: const [
                                BoxShadow(color: Colors.black, blurRadius: 1),
                              ],
                            ),
                            onPressed: () => widget.onReact(widget.message.id, true),
                          ),
                          Text('${countReactions('good')}'),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.thumb_down,
                              color: userHasReacted('bad')
                                  ? Colors.red
                                  : Color(0xFFD3D3D3),
                              shadows: const [
                                BoxShadow(color: Colors.black, blurRadius: 1),
                              ],
                            ),
                            onPressed: () => widget.onReact(widget.message.id, false),
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
                right: 50,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.reply, color: Color(0xFFD3D3D3), shadows: const [
                      BoxShadow(color: Colors.black, blurRadius: 1),
                    ]),
                    onPressed: () {
                      widget.onReply(widget.message.id, widget.message);
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

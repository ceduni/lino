import 'package:flutter/material.dart';
import 'package:Lino_app/services/thread_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_services.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'message_tile.dart'; // Import the MessageTile

class ThreadMessagesScreen extends StatefulWidget {
  final String threadId;
  final String title;

  ThreadMessagesScreen({required this.threadId, required this.title});

  @override
  _ThreadMessagesScreenState createState() => _ThreadMessagesScreenState();
}

class _ThreadMessagesScreenState extends State<ThreadMessagesScreen> {
  List<dynamic> messages = [];
  bool isLoading = true;
  bool isUserAuthenticated = false;
  String token = '';
  String? respondsTo;
  Map<String, dynamic>? respondingToMessage;
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchThreadMessages();
    checkUser();
  }

  Future<void> fetchThreadMessages() async {
    final ts = ThreadService();
    final response = await ts.getThread(widget.threadId);
    setState(() {
      messages = response['messages'];
      isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> checkUser() async {
    final us = UserService();
    final prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('token');
    if (storedToken != null) {
      try {
        final response = await us.getUser(storedToken);
        setState(() {
          isUserAuthenticated = true;
          token = storedToken;
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  Future<void> sendMessage() async {
    if (_controller.text.isNotEmpty) {
      try {
        final ts = ThreadService();
        await ts.addMessage(token, widget.threadId, _controller.text, respondsTo: respondsTo);
        _controller.clear();
        setState(() {
          respondsTo = null;
          respondingToMessage = null;
        });
        fetchThreadMessages(); // Refresh messages after sending
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent); // Scroll to bottom after sending
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  Future<void> handleReaction(String messageId, bool isGood) async {
    try {
      final ts = ThreadService();
      await ts.toggleMessageReaction(token, widget.threadId, messageId, isGood);
      fetchThreadMessages(); // Refresh messages after reaction
    } catch (e) {
      print('Error reacting to message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageTile(
                  message: message,
                  allMessages: messages,
                  onReact: handleReaction,
                  onReply: (String messageId, Map<String, dynamic> message) {
                    setState(() {
                      respondsTo = messageId;
                      respondingToMessage = message;
                    });
                  },
                );
              },
            ),
          ),
          if (respondingToMessage != null)
            RespondingToMessagePreview(
              respondingToMessage: respondingToMessage!,
              onClose: () {
                setState(() {
                  respondsTo = null;
                  respondingToMessage = null;
                });
              },
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    enabled: isUserAuthenticated, // Disable input if not authenticated
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: isUserAuthenticated ? sendMessage : null, // Disable button if not authenticated
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RespondingToMessagePreview extends StatelessWidget {
  final Map<String, dynamic> respondingToMessage;
  final VoidCallback onClose;

  RespondingToMessagePreview({required this.respondingToMessage, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${respondingToMessage['username']}: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: respondingToMessage['content'],
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

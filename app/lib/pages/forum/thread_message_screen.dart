import 'package:flutter/material.dart';
import 'package:Lino_app/services/thread_services.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'message_tile.dart';

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
  String? currentUsername;

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
    final prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('token');
    if (storedToken != null) {
      try {
        var us = UserService();
        final response = await us.getUser(storedToken);
        setState(() {
          isUserAuthenticated = true;
          token = storedToken;
          currentUsername = response['user']['username'];
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
        await ts.addMessage(token, widget.threadId, _controller.text,
            respondsTo: respondsTo);
        _controller.clear();
        setState(() {
          respondsTo = null;
          respondingToMessage = null;
        });
        fetchThreadMessages(); // Refresh messages after sending
        _scrollController.jumpTo(_scrollController
            .position.maxScrollExtent); // Scroll to bottom after sending
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
      body: Container(
        color: LinoColors.primary,
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final messageUsername = message['username'];
                        final isCurrentUser =
                            messageUsername == currentUsername;
                        return MessageTile(
                          message: message,
                          allMessages: messages,
                          onReact: handleReaction,
                          onReply:
                              (String messageId, Map<String, dynamic> message) {
                            setState(() {
                              respondsTo = messageId;
                              respondingToMessage = message;
                            });
                          },
                          backgroundColor: isCurrentUser
                              ? LinoColors.secondary
                              : LinoColors.primaryBackground,
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
              padding: const EdgeInsets.all(0),
              child: Container(
                color: Color(0xFF6098FF), // Set the background color of the row
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0), // Add vertical padding for elevation
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          fillColor: Colors.grey[200],
                          filled: true,
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        enabled: isUserAuthenticated, // Disable input if not authenticated
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: isUserAuthenticated ? Colors.grey.shade100 : Colors.grey.shade400),
                      onPressed: isUserAuthenticated ? sendMessage : null, // Disable button if not authenticated
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class RespondingToMessagePreview extends StatelessWidget {
  final Map<String, dynamic> respondingToMessage;
  final VoidCallback onClose;

  const RespondingToMessagePreview(
      {required this.respondingToMessage, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color(0xFF6098FF),
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

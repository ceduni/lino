import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/book_services.dart';
import '../../services/user_services.dart';
import '../../utils/constants/colors.dart';

class RequestsSection extends StatefulWidget {
  const RequestsSection({super.key});

  @override
  RequestsSectionState createState() => RequestsSectionState();
}

class RequestsSectionState extends State<RequestsSection> {
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    fetchRequests();
  }

  Future<void> fetchCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final user = await UserService().getUser(token);
      setState(() {
        currentUsername = user['user']['username'];
      });
    }
  }

  Future<void> fetchRequests() async {
    try {
      var bs = BookService();
      final List<dynamic> requestList = await bs.getBookRequests();
      setState(() {
        requests = requestList.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LinoColors.primary,
      child: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final isOwner = request['username'] == currentUsername;

              return GestureDetector(
                onLongPress: isOwner
                    ? () {
                  _showDeleteDialog(context, request['_id'], request['bookTitle']);
                }
                    : null,
                child: Dismissible(
                  key: Key(request['_id']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Match the margin of the card
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8.0), // Match the border radius of the card
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (isOwner) {
                      return await _showDeleteDialog(context, request['_id'], request['bookTitle']);
                    }
                    return false;
                  },
                  child: Card(
                    color: isOwner ? LinoColors.accent : LinoColors.secondary,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Add margin between cards
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Match the border radius
                    ),
                    child: ListTile(
                      title: Text(request['bookTitle'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: request['customMessage'] != null ? Text(request['customMessage']) : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (request['isFulfilled']) Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context, String requestId, String bookTitle) async {
    final deleteConfirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete your request for "$bookTitle"?'),
        content: Text('You won\'t be notified when the book you want will be added to a bookbox.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (deleteConfirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        try {
          await BookService().deleteBookRequest(token, requestId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Request deleted successfully!')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }

    return deleteConfirmed;
  }
}

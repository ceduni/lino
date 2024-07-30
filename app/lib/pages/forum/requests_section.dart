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
              return Card(
                color: isOwner ? LinoColors.accent : LinoColors.secondary,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Add margin between cards
                child: ListTile(
                  title: Text(request['bookTitle'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: request['customMessage'] != null ? Text(request['customMessage']) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (request['isFulfilled']) Icon(Icons.check_circle, color: Colors.green),
                      if (isOwner)
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, shadows: const [
                            BoxShadow(color: Colors.black, blurRadius: 1),
                          ]),
                          onPressed: () async {
                            final deleteConfirmed = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete your request for "${request['bookTitle']}"?'),
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
                                  await BookService().deleteBookRequest(token, request['_id']);
                                  setState(() {
                                    requests.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Request deleted successfully!')),
                                  );
                                } catch (e) {
                                  print(e);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: ${e.toString()}')),
                                  );
                                }
                              }
                            }
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

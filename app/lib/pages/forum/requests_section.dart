import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/book_services.dart';

class RequestsSection extends StatelessWidget {
  const RequestsSection({super.key});

  Future<bool> hasUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  Future<void> _showRequestForm(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return; // Token is missing, do nothing
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: RequestForm(token: token),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Text('Requests Section'),
        ),
        FutureBuilder<bool>(
          future: hasUserToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(); // While loading
            } else if (snapshot.hasData && snapshot.data == true) {
              return Positioned(
                bottom: 20,
                left: 20,
                child: FloatingActionButton(
                  onPressed: () => _showRequestForm(context),
                  child: Icon(Icons.add),
                  backgroundColor: Colors.blue,
                ),
              );
            } else {
              return Container(); // No token or an error
            }
          },
        ),
      ],
    );
  }
}

class RequestForm extends StatefulWidget {
  final String token;

  RequestForm({required this.token});

  @override
  _RequestFormState createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        var bs = BookService();
        await bs.requestBookToUsers(
          widget.token,
          _titleController.text,
          cm: _messageController.text,
        );

        Navigator.of(context).pop(); // Close the modal

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request sent successfully!')),
        );
      } catch (e) {
        Navigator.of(context).pop(); // Close the modal if there's an error

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
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Book Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the title of the book';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Custom Message (optional)'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submitForm,
              child: Text('Send Request'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/book_services.dart';

class RequestForm extends StatefulWidget {
  final VoidCallback onRequestCreated;

  const RequestForm({required this.onRequestCreated, Key? key}) : super(key: key);

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
        final token = await SharedPreferences.getInstance().then((prefs) => prefs.getString('token'));
        await bs.requestBookToUsers(
          token!,
          _titleController.text,
          cm: _messageController.text,
        );

        widget.onRequestCreated();  // Call the callback to re-fetch requests

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

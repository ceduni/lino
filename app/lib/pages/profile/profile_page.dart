import 'package:Lino_app/models/user_model.dart';
import 'package:Lino_app/widgets/user_dashboard/user_dashboard_widget.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'options_page.dart';
  
class ProfilePage extends HookWidget {
  const ProfilePage({super.key});

  Future<String?> initializePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<User> getUserData(String token) async {
    return await UserService().getUser(token);
  }


  Widget buildContent(BuildContext context, User user) {
    return UserDashboard(
      user: user,
    );
  }

  Future<void> _disconnect(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialized = useState(false);
    final token = useState<String?>(null);

    useEffect(() {
      initializePrefs().then((value) {
        token.value = value;
        initialized.value = true;
      });
      return null;
    }, []);

    if (!initialized.value) {
      return Center(child: CircularProgressIndicator());
    }

    if (token.value == null || token.value!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Profile Test'),
        ),
        body: Center(child: Text('No token found. Please log in.')),
      );
    }

    final userData =
    useFuture(useMemoized(() => getUserData(token.value!), [token.value]));

    if (userData.connectionState != ConnectionState.done) {
      return Center(child: CircularProgressIndicator());
    }

    if (userData.hasError || userData.data == null) {
      return Center(child: Text('Error loading data or user data is null'));
    }

    final username = userData.data!.username;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(125, 200, 237, 1),
        title: Text(username),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OptionsPage(),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.settings, color: Colors.white),
                Text(
                  'Options',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () => _disconnect(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.red),
                Text(
                  'Disconnect',
                  style: TextStyle(color: Colors.red, fontSize: 10),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: buildContent(context, userData.data!),
    );
  }
}

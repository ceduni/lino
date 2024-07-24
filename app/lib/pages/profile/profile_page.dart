import 'package:Lino_app/pages/profile/user_dashboard_widget.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends HookWidget {
  SharedPreferences? prefs;
  String? token;

  ProfilePage({Key? key}) {
    initializePrefs();
  }

  Future<void> initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    token = prefs!.getString('token');
    print('token: $token');
  }

  Future<Map<String, dynamic>> getUserData(String token) async {
    var user = await UserService().getUser(token);
    print('User data: $user');
    return user;
  }

  Widget buildContent(BuildContext context, Map<String, dynamic> userData) {
    userData = userData['user'];

    double carbonSavings = userData['ecologicalImpact']['carbonSavings'];
    double savedWater = userData['ecologicalImpact']['savedWater'];
    double savedTrees = userData['ecologicalImpact']['savedTrees'];
    // int booksBorrowed = userData['bookHistory']['booksBorrowed'];
    // int booksGiven = userData['bookHistory']['booksGiven'];

    int booksBorrowed = 0;
    int booksGiven = 0;

    // print(userData['bookHistory'].runtimeType);
    // print(userData['favoriteBooks'].runtimeType);
    // print(userData['trackedBooks'].runtimeType);

    List<dynamic> dynamicBooksHistory = userData['bookHistory'];
    List<dynamic> dynamicFavoriteBooks = userData['favoriteBooks'];
    List<dynamic> dynamicTrackedBooks = userData['trackedBooks'];

    // Function to transform List<dynamic> to List<Map<String, dynamic>>
    List<Map<String, dynamic>> transformToMapList(List<dynamic> dynamicList) {
      return dynamicList.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else {
          throw TypeError(); // Handle unexpected item type appropriately
        }
      }).toList();
    }

    // Transform the dynamic lists to List<Map<String, dynamic>>
    List<Map<String, dynamic>> booksHistory =
        transformToMapList(dynamicBooksHistory);
    List<Map<String, dynamic>> favoriteBooks =
        transformToMapList(dynamicFavoriteBooks);
    List<Map<String, dynamic>> trackedBooks =
        transformToMapList(dynamicTrackedBooks);

    // List<Map<String, dynamic>> booksHistory = userData['bookHistory'];
    // List<Map<String, dynamic>> favoriteBooks = userData['favoriteBooks'];
    // List<Map<String, dynamic>> trackedBooks = userData['trackedBooks'];

    return UserDashboard(
      favoriteBooks: favoriteBooks,
      trackedBooks: trackedBooks,
      booksHistory: booksHistory,
      username: userData['username'],
      carbonSavings: carbonSavings,
      savedWater: savedWater,
      savedTrees: savedTrees,
      booksBorrowed: booksBorrowed,
      booksGiven: booksGiven,
    );
    // // return Column(
    // //   children: [
    // //     Center(
    // //       child: Text(userData.toString()),
    // //     ),
    // //     Center(child: Text(userData['username'].toString())),
    // //     Center(child: Text(userData['email'].toString())),
    // //     Center(child: Text(userData['phone'].toString())),
    // //     Center(child: Text(userData['getAlerted'].toString())),
    // //     Center(child: Text(userData['ecologicalImapct'].toString())),
    // //     Center(child: Text(userData['favoriteBooks'].toString())),
    // //     Center(child: Text(userData['trackedBooks'].toString())),
    // //     Center(child: Text(userData['notificationKeyWords'].toString())),
    // //     Center(child: Text(userData['notifications'].toString())),
    // //     Center(child: Text(userData['bookHistory'].toString())),
    // //   ],
    // // );
  }

  @override
  Widget build(BuildContext context) {
    final initialized = useState(false);

    useEffect(() {
      initializePrefs().then((_) {
        initialized.value = true;
      });
      return null;
    }, []);

    if (!initialized.value) {
      return Center(child: CircularProgressIndicator());
    }

    final userData = useFuture(useMemoized(() => getUserData(token!), [token]));

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile Test'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // TODO: add onPressed function here
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => LoginPage(),
              //   ),
              // );
            },
          ),
        ],
      ),
      body: userData.connectionState == ConnectionState.waiting
          ? Center(child: CircularProgressIndicator())
          : userData.hasError
              ? Center(child: Text('Error loading data'))
              : buildContent(context, userData.data!),
    );
  }
}

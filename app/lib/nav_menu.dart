import 'package:Lino_app/views/search/search_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:Lino_app/pages/map/map_screen.dart';
import 'package:Lino_app/pages/floating_button/floating_action_button.dart';
import 'package:Lino_app/pages/forum/forum_screen.dart';
// import 'package:Lino_app/pages/forum/requests_section.dart';
import 'package:Lino_app/views/layout/appbar.dart';
import 'package:Lino_app/views/profile/profile_page.dart';
import 'package:Lino_app/views/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_services.dart';

class BookNavPage extends StatefulWidget {
  const BookNavPage({super.key});

  @override
  _BookNavPageState createState() => _BookNavPageState();
}

class _BookNavPageState extends State<BookNavPage> {
  late Future<bool> _isUserLoggedInFuture;

  @override
  void initState() {
    super.initState();
    _isUserLoggedInFuture = _isUserLoggedIn();
  }

  Future<bool> _isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;
    try {
      final userService = UserService();
      await userService.getUser(token);
      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      appBar: OBxLinoAppBar(controller: controller),
      floatingActionButton: Obx(() {
        if (controller.selectedIndex.value == 0 || controller.selectedIndex.value == 3) {
          // pr cacher
          return SizedBox.shrink();
        } else if (controller.selectedIndex.value == 2) {
          // Requests page is active
          return LinoFloatingButton(
            selectedIndex: controller.selectedIndex.value,
            // onThreadCreated: () => // Commented out - threads functionality removed
            //     controller.forumScreenKey.currentState?.refreshThreads(),
            onRequestCreated: () =>
                controller.forumScreenKey.currentState?.refreshRequests(),
          );
        } else {
          // Default Floating Button
          return SizedBox.shrink();
        }
      }),
      bottomNavigationBar: _buildNavigationBar(context, controller),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }

  Widget _buildNavigationBar(BuildContext context, NavigationController controller) {
    return GetBuilder<NavigationController>(
      builder: (controller) {
        return FutureBuilder<bool>(
          future: _isUserLoggedInFuture,
          builder: (context, snapshot) {
            bool isLoggedIn = snapshot.data ?? false;
            
            return NavigationBar(
              height: 80,
              elevation: 10, 
              selectedIndex: controller.selectedIndex.value,
              indicatorColor: Color.fromRGBO(239, 174, 133, 1),
              onDestinationSelected: (index) async {
                if (index == 3) { // Profile tab index
                  if (!isLoggedIn) {
                    // User not logged in, redirect to login instead of showing profile tab
                    Navigator.of(context).pushReplacementNamed('/login');
                  } else {
                    // User logged in, show profile tab like other tabs
                    controller.selectedIndex.value = index;
                    controller.update(); // Trigger rebuild
                  }
                } else {
                  // Normal tab selection for other tabs
                  controller.selectedIndex.value = index;
                  controller.update(); // Trigger rebuild
                }
              },
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                /*NavigationDestination(
                  icon: Icon(Icons.map),
                  label: 'Map',
                ),*/
                NavigationDestination(
                  icon: Icon(Icons.chat),
                  label: 'Requests',
                ),
                NavigationDestination(
                  icon: Icon(isLoggedIn ? Icons.person : Icons.login),
                  label: isLoggedIn ? 'Profile' : 'Log In',
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class NavigationController extends GetxController {
  late Rx<int> selectedIndex = 0.obs;
  final GlobalKey<ForumScreenState> forumScreenKey =
  GlobalKey<ForumScreenState>();
  final RxString sourcePage = ''.obs;
  late String forumQuery;

  late final List<Widget> screens;

  NavigationController() {
    forumQuery = '';
    screens = [
      HomePage(),
      SearchPage(),
      //MapScreen(),
      ForumScreen(key: forumScreenKey, query: forumQuery),
      ProfilePage()
    ];
  }

  void navigateToForumWithQuery(String query) {
    forumQuery = query;
    selectedIndex.value = 2; // Set to Requests tab
    screens[2] = ForumScreen(
        key: forumScreenKey,
        query: forumQuery); // Update ForumScreen with new query
  }
}

class OBxLinoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final NavigationController controller;
  
  const OBxLinoAppBar({Key? key, required this.controller}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Obx(() => LinoAppBar(sourcePage: controller.selectedIndex.value));
  }
}

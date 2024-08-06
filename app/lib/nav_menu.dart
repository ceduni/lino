import 'package:Lino_app/pages/Books/book_nav_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Lino_app/pages/map/map_screen.dart';
import 'package:Lino_app/pages/floating_button/floating_action_button.dart';
import 'package:Lino_app/pages/forum/forum_screen.dart';
import 'package:Lino_app/pages/appbar/observable_appbar.dart';
import 'package:Lino_app/pages/search_bar/results_screen.dart';
import 'package:Lino_app/pages/search_bar/search_bar.dart' as sb;

class BookNavPage extends StatelessWidget {
  const BookNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final searchController = Get.put(sb.SearchController());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: ObservableAppBar(
            sourcePage: controller.selectedIndex),
      ),
      floatingActionButton: Obx(() {
        if (controller.selectedIndex.value == 2) {
          // Forum page is active
          return LinoFloatingButton(
            selectedIndex: controller.selectedIndex.value,
            onThreadCreated: () =>
                controller.forumScreenKey.currentState?.refreshThreads(),
            onRequestCreated: () =>
                controller.forumScreenKey.currentState?.refreshRequests(),
          );
        } else {
          // Default Floating Button
          return LinoFloatingButton(
              selectedIndex: controller.selectedIndex.value);
        }
      }),
      bottomNavigationBar: Obx(() => _buildNavigationBar(controller)),
      body: Stack(
        children: [
          Obx(() => controller.screens[controller.selectedIndex.value]),
          Obx(() {
            if (searchController.query.isNotEmpty) {
              return Positioned.fill(
                child: ResultsPage(
                  query: searchController.query.value,
                  sourcePage: controller.selectedIndex.value,
                  onBack: searchController.hideSearchResults,
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(NavigationController controller) {
    return NavigationBar(
      height: 80,
      elevation: 10,
      selectedIndex: controller.selectedIndex.value,
      indicatorColor: Color.fromRGBO(239, 174, 133, 1),
      onDestinationSelected: (index) => controller.selectedIndex.value = index,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.book),
          label: 'Books',
        ),
        NavigationDestination(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat),
          label: 'Forum',
        ),
      ],
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
      NavigationPage(),
      MapScreen(),
      ForumScreen(key: forumScreenKey, query: forumQuery),
    ];
  }

  void navigateToForumWithQuery(String query) {
    forumQuery = query;
    selectedIndex.value = 2; // Set to Forum tab
    screens[2] = ForumScreen(
        key: forumScreenKey,
        query: forumQuery); // Update ForumScreen with new query
  }
}

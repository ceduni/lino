import 'package:Lino_app/pages/Books/book_nav_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Lino_app/pages/appbar/appbar.dart';
import 'package:Lino_app/pages/map/map_screen.dart';
import 'package:Lino_app/pages/search_bar/search_bar.dart' as search_bar;
import 'package:Lino_app/pages/floating_button/floating_action_button.dart';
import 'package:Lino_app/pages/forum/forum_screen.dart';

class BookNavPage extends StatelessWidget {
  const BookNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final searchController = Get.put(search_bar.SearchController());

    return Scaffold(
      appBar: LinoAppBar(),
      floatingActionButton: Obx(() {
        if (controller.selectedIndex.value == 2) {
          // Forum page is active
          return LinoFloatingButton(
            selectedIndex: controller.selectedIndex.value,
            onThreadCreated: () => controller.forumScreenKey.currentState?.refreshThreads(),
            onRequestCreated: () => controller.forumScreenKey.currentState?.refreshRequests(),
          );
        } else {
          // Default Floating Button
          return LinoFloatingButton(selectedIndex: controller.selectedIndex.value);
        }
      }),
      bottomNavigationBar: Obx(() => _buildNavigationBar(controller)),
      body: Stack(
        children: [
          Obx(() => controller.screens[controller.selectedIndex.value]),
          Obx(() => _buildSearchResults(searchController)),
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

  Widget _buildSearchResults(search_bar.SearchController searchController) {
    if (searchController.results.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      color: Color.fromRGBO(211, 242, 255, 1),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: searchController.results.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(searchController.results[index]),
          );
        },
      ),
    );
  }
}


class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final GlobalKey<ForumScreenState> forumScreenKey = GlobalKey<ForumScreenState>();

  late final List<Widget> screens;

  NavigationController() {
    screens = [
      NavigationPage(),
      MapScreen(),
      ForumScreen(key: forumScreenKey),
    ];
  }
}


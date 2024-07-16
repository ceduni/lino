import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Lino_app/common/widgets/appbar/appbar.dart';
import 'pages/navigation.dart';
import 'package:Lino_app/common/widgets/floating_action_button/floating_action_button.dart';
import 'package:Lino_app/pages/forum/forum_screen.dart';
import 'package:Lino_app/pages/map_screen.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/common/widgets/appbar/search_bar.dart'
    as search_bar; // Avoid naming conflict

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final searchController = Get.put(search_bar.SearchController());

    return Scaffold(
      appBar: LinoAppBar(),
      floatingActionButton: LinoFloatingButton(),
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
      indicatorColor: LinoColors.accent,
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
      color: Colors.grey.withOpacity(0.5),
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
  final screens = [
    NavigationPage(),
    MapScreen(),
    ForumScreen(),
  ];
}

class BooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(child: Text('Placeholder for Books Screen')),
    );
  }
}



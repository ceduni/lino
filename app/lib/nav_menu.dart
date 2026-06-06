import 'package:lino_app/utils/constants/colors.dart';
import 'package:lino_app/utils/constants/routes.dart';
import 'package:lino_app/views/search/search_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lino_app/views/forum/forum_screen.dart';
import 'package:lino_app/views/layout/appbar.dart';
import 'package:lino_app/views/profile/profile_page.dart';
import 'package:lino_app/views/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_services.dart';
import 'package:lino_app/l10n/app_localizations.dart';

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

    return Obx(() => Scaffold(
          appBar: controller.selectedIndex.value == 0
              ? null
              : LinoAppBar(sourcePage: controller.selectedIndex.value),
          bottomNavigationBar: _buildNavigationBar(context, controller),
          body: controller.screens[controller.selectedIndex.value],
        ));
  }

  Widget _buildNavigationBar(BuildContext context, NavigationController controller) {
  final localizations = AppLocalizations.of(context)!;

  return GetBuilder<NavigationController>(
    builder: (controller) {
      return FutureBuilder<bool>(
        future: _isUserLoggedInFuture,
        builder: (context, snapshot) {
          bool isLoggedIn = snapshot.data ?? false;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: 65, // Reduced from 75
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.home_rounded,
                      selectedIcon: Icons.home,
                      label: localizations.navHome,
                      index: 0,
                      isSelected: controller.selectedIndex.value == 0,
                      onTap: () {
                        controller.selectedIndex.value = 0;
                        controller.update();
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.search_rounded,
                      selectedIcon: Icons.search,
                      label: localizations.navSearch,
                      index: 1,
                      isSelected: controller.selectedIndex.value == 1,
                      onTap: () {
                        controller.selectedIndex.value = 1;
                        controller.update();
                      },
                    ),
                    _buildNavItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      selectedIcon: Icons.chat_bubble_rounded,
                      label: localizations.navRequests,
                      index: 2,
                      isSelected: controller.selectedIndex.value == 2,
                      onTap: () {
                        controller.selectedIndex.value = 2;
                        controller.update();
                      },
                    ),
                    _buildNavItem(
                      icon: isLoggedIn ? Icons.person_outline_rounded : Icons.login_rounded,
                      selectedIcon: isLoggedIn ? Icons.person_rounded : Icons.login_rounded,
                      label: isLoggedIn ? localizations.navProfile : localizations.navLogIn,
                      index: 3,
                      isSelected: controller.selectedIndex.value == 3,
                      onTap: () async {
                        if (!isLoggedIn) {
                          Get.offNamed(AppRoutes.auth.login);
                        } else {
                          controller.selectedIndex.value = 3;
                          controller.update();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
Widget _buildNavItem({
  required IconData icon,
  required IconData selectedIcon,
  required String label,
  required int index,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: const Color.fromRGBO(31, 73, 125, 0.1),
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: isSelected ? 52 : 36, // Slightly larger when selected
              height: isSelected ? 52 : 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected 
                    ? LinoColors.accent
                    : Colors.transparent,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color.fromRGBO(31, 73, 125, 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    key: ValueKey<bool>(isSelected),
                    color: isSelected 
                        ? Colors.white 
                        : const Color.fromRGBO(100, 116, 139, 1),
                    size: isSelected ? 28 : 22,
                  ),
                ),
              ),
            ),
            // Show label only when NOT selected
            if (!isSelected) ...[
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color.fromRGBO(100, 116, 139, 1),
                  fontFamily: 'Kanit-Bold',
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

//   Widget _buildNavigationBar(BuildContext context, NavigationController controller) {
//     final localizations = AppLocalizations.of(context)!;

//     return GetBuilder<NavigationController>(
//       builder: (controller) {
//         return FutureBuilder<bool>(
//           future: _isUserLoggedInFuture,
//           builder: (context, snapshot) {
//             bool isLoggedIn = snapshot.data ?? false;

//             return NavigationBar(
//               height: 80,
//               elevation: 10,
//               selectedIndex: controller.selectedIndex.value,
//               indicatorColor: Color.fromRGBO(239, 174, 133, 1),
//               onDestinationSelected: (index) async {
//                 if (index == 3) {
//                   // Profile tab index
//                   if (!isLoggedIn) {
//                     // User not logged in, redirect to login instead of showing profile tab
//                     Get.offNamed(AppRoutes.auth.login);
//                   } else {
//                     // User logged in, show profile tab like other tabs
//                     controller.selectedIndex.value = index;
//                     controller.update(); // Trigger rebuild
//                   }
//                 } else {
//                   // Normal tab selection for other tabs
//                   controller.selectedIndex.value = index;
//                   controller.update(); // Trigger rebuild
//                 }
//               },
//               labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
//               destinations: [
//                 NavigationDestination(
//                   icon: Icon(Icons.home),
//                   label: localizations.navHome,
//                 ),
//                 NavigationDestination(
//                   icon: Icon(Icons.search),
//                   label: localizations.navSearch,
//                 ),
//                 /*NavigationDestination(
//                   icon: Icon(Icons.map),
//                   label: 'Map',
//                 ),*/
//                 NavigationDestination(
//                   icon: Icon(Icons.chat),
//                   label: localizations.navRequests,
//                 ),
//                 NavigationDestination(
//                   icon: Icon(isLoggedIn ? Icons.person : Icons.login),
//                   label: isLoggedIn ? localizations.navProfile : localizations.navLogIn,
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
}

class NavigationController extends GetxController {
  late Rx<int> selectedIndex = 0.obs;
  final RxString sourcePage = ''.obs;
  late String forumQuery;

  late final List<Widget> screens;

  NavigationController() {
    forumQuery = '';
    screens = [
      HomePage(),
      SearchPage(),
      //MapScreen(),
      ForumScreen(query: forumQuery),
      ProfilePage()
    ];
  }

  void navigateToForumWithQuery(String query) {
    forumQuery = query;
    selectedIndex.value = 2; // Set to Requests tab
    screens[2] = ForumScreen(query: forumQuery); // Update ForumScreen with new query
  }
}

class OBxLinoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final NavigationController controller;

  const OBxLinoAppBar({super.key, required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Obx(() => LinoAppBar(sourcePage: controller.selectedIndex.value));
  }
}

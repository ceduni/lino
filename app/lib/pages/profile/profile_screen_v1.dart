import 'package:Lino_app/pages/profile/expansion_list.dart';
import 'package:Lino_app/pages/profile/favorite_book_widget.dart';
import 'package:Lino_app/pages/profile/history_widget.dart';
import 'package:Lino_app/pages/profile/notification_widget.dart';
import 'package:Lino_app/pages/profile/statistical_widget.dart';
import 'package:Lino_app/utils/constants/sizes.dart';
import 'package:Lino_app/utils/mock_data/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// TODO: Put widgets in separate files

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Screen'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Center(
            child: Text(
              'John Doe',
              style: TextStyle(fontSize: 30),
            ),
          ),
          SizedBox(height: LinoSizes.spaceBtwItems),
          ProfileSectionList(),
          SizedBox(height: LinoSizes.spaceBtwSections),
          Center(
              child: Text(
            'Settings',
            style: TextStyle(fontSize: 30),
          )),
          SizedBox(height: LinoSizes.spaceBtwItems),
          SettingsSectionList(),
        ]),
      ),
    );
  }
}

class ProfileExpansionPanelController extends GetxController {
  var isExpanded = <bool>[true, true, true, true, true].obs;
  // If adding more panels, add more false values to the list above
  void togglePanel(int index) {
    isExpanded[index] = !isExpanded[index];
  }
}

class ProfileSectionList extends StatelessWidget {
  final ProfileExpansionPanelController controller =
      Get.put(ProfileExpansionPanelController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Obx(
        () => ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            controller.togglePanel(index);
          },
          children: [
            CustomExpansionPanel(
              headerText: 'Historique',
              // bodyText: 'Content of Historique',
              body: HistoryWidget(books: MockData.getBooks()),
              isExpanded: controller.isExpanded[0],
            ),
            CustomExpansionPanel(
              headerText: 'Statistiques',
              body: StatisticalWidget(),
              isExpanded: controller.isExpanded[1],
            ),
            CustomExpansionPanel(
              headerText: 'Achievements',
              bodyText: 'Content of Achievements',
              isExpanded: controller.isExpanded[2],
            ),
            CustomExpansionPanel(
              headerText: 'Preferences',
              bodyText: 'Content of Preferences',
              isExpanded: controller.isExpanded[3],
            ),
            CustomExpansionPanel(
              headerText: 'Favoris',
              body: FavoriteBookWidget(favoriteBooks: MockData.getBooks()),
              isExpanded: controller.isExpanded[4],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingExpansionPanelController extends GetxController {
  var isExpanded = <bool>[true, true].obs;
  // If adding more panels, add more false values to the list above
  void togglePanel(int index) {
    isExpanded[index] = !isExpanded[index];
  }
}

class SettingsSectionList extends StatelessWidget {
  final SettingExpansionPanelController controller =
      Get.put(SettingExpansionPanelController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Obx(
        () => ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            controller.togglePanel(index);
          },
          children: [
            CustomExpansionPanel(
              headerText: 'Notifications',
              body: NotificationWidget(),
              isExpanded: controller.isExpanded[0],
            ),
            CustomExpansionPanel(
              headerText: 'Langues',
              bodyText: 'Content of Langues',
              isExpanded: controller.isExpanded[1],
            ),
          ],
        ),
      ),
    );
  }
}

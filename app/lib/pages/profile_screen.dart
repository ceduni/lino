import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Center(
        child: Text(
          'Profile Screen',
          style: TextStyle(fontSize: 30),
        ),
      ),
      ProfileSectionList(),
      Center(
          child: Text(
        'Settings',
        style: TextStyle(fontSize: 30),
      )),
      SettingsSectionList(),
    ]);
  }
}

class ProfileExpansionPanelController extends GetxController {
  var isExpanded = <bool>[false, false, false, false, false].obs;
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
              bodyText: 'Content of Historique',
              isExpanded: controller.isExpanded[0],
            ),
            CustomExpansionPanel(
              headerText: 'Statistiques',
              bodyText: 'Content of Statistiques',
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
              bodyText: 'Content of Favoris',
              isExpanded: controller.isExpanded[4],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingExpansionPanelController extends GetxController {
  var isExpanded = <bool>[false, false].obs;
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
              bodyText: 'Content of Notifications',
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

class CustomExpansionPanel extends ExpansionPanel {
  CustomExpansionPanel({
    Key? key,
    required String headerText,
    required String bodyText,
    bool isExpanded = false,
  }) : super(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(headerText),
            );
          },
          body: ListTile(
            title: Text(bodyText),
          ),
          isExpanded: isExpanded,
        );
}

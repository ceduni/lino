import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/utils/constants/default_placeholder.dart';
import 'package:Lino_app/utils/constants/sizes.dart';
import 'package:Lino_app/utils/mock_data/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Center(
          child: Text(
            'John Doe',
            style: TextStyle(fontSize: 30),
          ),
        ),
        SizedBox(height: LinoSizes.spaceBtwSections),
        Center(
          child: Text(
            'Profile Screen',
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
    String? bodyText,
    Widget? body,
    bool isExpanded = false,
  }) : super(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(headerText),
            );
          },
          body: ListTile(
            title: bodyText != null ? Text(bodyText) : body,
          ),
          isExpanded: isExpanded,
        );
}

class HistoryWidget extends StatelessWidget {
  final List<Book> books;

  const HistoryWidget({required this.books});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: LinoSizes.gridViewSpacing,
        mainAxisSpacing: LinoSizes.gridViewSpacing,
        childAspectRatio: 0.7,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return BookGridContainer(
          imagePath: books[index].coverImage ?? LinoDefaults.coverImage,
          title: books[index].title,
          date: books[index].dateLastAction,
        );
      },
    );
  }
}

class BookGridContainer extends StatelessWidget {
  final String imagePath;
  final String title;
  final DateTime date;

  const BookGridContainer(
      {required this.imagePath, required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Image.asset(imagePath), Text(title), Text(date.toString())],
    );
  }
}

class AchievementWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

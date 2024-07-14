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

class StatisticalWidget extends StatelessWidget {
  // Separate into 2 sections:
  // Sec 1: Personal Impact, Community Impact(2 tiles)
  // Personal Impact: Carbon savings, water saved, trees saved
  // Community Impact: Carbon savings, water saved, trees saved

  // Sec 2: Personal Preferences (3 tiles)
  // Favorite genre, nb books borrowed, nb books given

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          children: [
            GridTileWidget(
              title: 'Personal Impact',
              icon: Icons.eco,
              navigateTo: Container(),
            ),
            GridTileWidget(
              title: 'Community Impact',
              icon: Icons.people,
              navigateTo: Container(),
            ),
          ],
        ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          children: [
            GridTileWidget(
              title: 'Books borrowed',
              icon: Icons.book,
              navigateTo: Container(),
            ),
            GridTileWidget(
              title: 'Favorite genre',
              icon: Icons.favorite,
              navigateTo: Container(),
            ),
            GridTileWidget(
              title: 'Books given',
              icon: Icons.book,
              navigateTo: Container(),
            ),
          ],
        ),
      ],
    );
  }
}

class GridTileWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget navigateTo;

  const GridTileWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.navigateTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => navigateTo),
        );
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50.0),
            SizedBox(height: 10.0),
            Text(title, style: TextStyle(fontSize: 20.0)),
          ],
        ),
      ),
    );
  }
}

class CheckboxController extends GetxController {
  var isChecked = false.obs;

  void toggleCheckbox() {
    isChecked.value = !isChecked.value;
  }
}

class ReusableCheckbox extends StatelessWidget {
  final String title;
  final void Function(bool?)? onChanged;
  final CheckboxController checkboxController;

  const ReusableCheckbox(
      {required this.title,
      required this.onChanged,
      required this.checkboxController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CheckboxListTile(
        title: Text(title),
        value: checkboxController.isChecked.value,
        onChanged: (bool? value) {
          checkboxController.toggleCheckbox();
          if (onChanged != null) {
            onChanged!(value);
          }
        },
      ),
    );
  }
}

// TODO: Write toggle function and add onChanged to the checkboxes
// TODO: Add preferences to users class or store in a separate file
// BUG: When toggle checkbox, the other checkbox is also toggled
class NotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReusableCheckbox(
          title: "Me demander lors de l'ajout d'un livre de mes demandes",
          onChanged: (value) {
            print('Checkbox 1: requested book added: $value');
          },
          checkboxController: Get.put(CheckboxController()),
        ),
        ReusableCheckbox(
          title:
              "Me demander lors de l'ajout d'un livre de mes recommendations",
          onChanged: (value) {
            print('Checkbox 2: recommended book added: $value');
          },
          checkboxController: Get.put(CheckboxController()),
        ),
      ],
    );
  }
}
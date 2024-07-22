import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

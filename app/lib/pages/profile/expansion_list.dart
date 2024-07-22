import 'package:flutter/material.dart';

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

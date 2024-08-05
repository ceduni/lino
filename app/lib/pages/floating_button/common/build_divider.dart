import 'package:flutter/material.dart';

Widget buildCustomDivider() {
  return const Row(children: <Widget>[
    Expanded(child: Divider()),
    Text('OR'),
    Expanded(child: Divider()),
  ]);
}

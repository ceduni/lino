import 'package:Lino_app/pages/profile/user_dashboard_widget.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends HookWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Hello World App'),
        ),
        body : const Center(
            child: Text('Hello, World!!!'),
          ),
        );
  }

}
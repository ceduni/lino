import 'package:flutter/material.dart';
import 'package:Lino_app/pages/profile/options/modify_profile_page.dart';
import 'package:Lino_app/pages/profile/options/favourite_genres_page.dart';
import 'package:Lino_app/utils/constants/colors.dart';

class OptionsPage extends StatefulWidget {
  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Options'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: LinoColors.primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.black),
                title: Text(
                  'Modify Profile',
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black),
                ),
                trailing:
                Icon(Icons.chevron_right, color: Colors.black),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ModifyProfilePage()),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: LinoColors.primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: Icon(Icons.favorite, color: Colors.black),
                title: Text(
                  'Setup Favourite Genres',
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black),
                ),
                trailing:
                Icon(Icons.chevron_right, color: Colors.black),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FavouriteGenresPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

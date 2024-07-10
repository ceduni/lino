import 'package:flutter/material.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data
    final List<String> imageUrls = [
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
      'https://via.placeholder.com/150',
    ];

    final List<String> banners = [
      'Banner 1',
      'Banner 2',
      'Banner 3',
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            for (var banner in banners) ...[
              Container(
                width: double.infinity,
                color: Colors.blue, // Set background color for the banner
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  banner,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set text color
                  ),
                ),
              ),
              Container(
                height: 150, // Set height for the row of images
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(imageUrls[index]),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

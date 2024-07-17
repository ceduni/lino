import 'package:flutter/material.dart';
import 'package:Lino_app/services/book_services.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookService = BookService();
    // final Future<Map<String, dynamic>> allBB = bookService.searchBookboxes();

    // Sample data for images
    final List<String> images = [
      'assets/croc_blanc.webp',
      'assets/croc_blanc.webp',
      'assets/croc_blanc.webp',
      'assets/croc_blanc.webp',
      'assets/croc_blanc.webp',
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
                  style: const TextStyle(
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
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to a new page with the image path
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageDetailPage(imagePath: images[index]),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(images[index]), // Use Image.asset for local images
                      ),
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

class ImageDetailPage extends StatelessWidget {
  final String imagePath;

  const ImageDetailPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Detail'),
      ),
      body: Center(
        child: Image.asset(imagePath), // Display the local image
      ),
    );
  }
}

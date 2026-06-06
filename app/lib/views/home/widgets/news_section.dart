import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lino_app/vm/home/home_view_model.dart';
import 'package:lino_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsSectionWidget extends StatelessWidget {
  final HomeViewModel viewModel;
  final AppLocalizations localizations;

  const NewsSectionWidget({
    super.key,
    required this.viewModel,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.newspaper_rounded,
                    color: Color.fromRGBO(31, 73, 125, 1),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Community News',
                    style: TextStyle(
                      fontFamily: 'UVNDzungDakao',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(31, 73, 125, 1),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () async {
                  final url = Uri.parse('https://montreal.ca/nouvelles?q=livre');
                  try {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    print('Could not launch $url: $e');
                    Get.snackbar(
                      'Error',
                      'Could not open the link',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text(
                  'See all',
                  style: TextStyle(
                    fontFamily: 'Kanit-Bold',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: viewModel.isLoadingNews
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromRGBO(66, 119, 184, 1),
                  ),
                )
              : viewModel.montrealNews.isEmpty
                  ? _buildNewsPlaceholder()
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      itemCount: viewModel.montrealNews.length,
                      itemBuilder: (context, index) {
                        return _buildNewsCard(viewModel.montrealNews[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            // Open article URL
            // launch(article.url);
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  article.imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 140,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 48, color: Colors.grey),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontFamily: 'Kanit-Bold',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(31, 73, 125, 1),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.date,
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No news available',
            style: TextStyle(
              fontFamily: 'UVNDzungDakao',
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
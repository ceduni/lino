import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/models/user_model.dart';
import 'package:Lino_app/services/bookbox_services.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:Lino_app/l10n/app_localizations.dart';

class FollowedBookboxesWidget extends StatefulWidget {
  final User user;

  const FollowedBookboxesWidget({
    super.key,
    required this.user,
  });

  @override
  State<FollowedBookboxesWidget> createState() => _FollowedBookboxesWidgetState();
}

class _FollowedBookboxesWidgetState extends State<FollowedBookboxesWidget> {
  List<BookBox>? followedBookboxes;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadFollowedBookboxes();
  }

  Future<void> _loadFollowedBookboxes() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        setState(() {
          error = 'No authentication token found';
          isLoading = false;
        });
        return;
      }

      final bookboxes = await BookboxService().getFollowedBookboxes(
        token,
        widget.user.followedBookboxes,
      );

      setState(() {
        followedBookboxes = bookboxes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    print('Building FollowedBookboxesWidget with ${followedBookboxes?.length ?? 0} bookboxes');
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.red, 
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.followedBookBoxes,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                if (followedBookboxes != null && followedBookboxes!.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.profile.followedBookboxes);
                    },
                    child: Text(localizations.viewall),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (error != null)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.errorLoadingFollowedBookboxes,
                      style: TextStyle(
                        color: Colors.red[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _loadFollowedBookboxes,
                      icon: const Icon(Icons.refresh),
                      label: Text(localizations.retry),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else if (followedBookboxes == null || followedBookboxes!.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.noFollowedBookboxes,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Kanit',
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.startFollowingBookboxes,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Kanit',
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              _buildBookboxesList(localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildBookboxCard(BookBox bookbox, AppLocalizations localization) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            AppRoutes.bookbox.main,
            arguments: {
              'bookboxId': bookbox.id,
              'canInteract': false,
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BookBox Image
              Expanded(
                flex: 3, // Give more space to image
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                  ),
                  child: bookbox.image != null && bookbox.image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            bookbox.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          ),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // BookBox Info
              Expanded(
                flex: 2, // Give less space to text info
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        bookbox.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.book,
                          size: 14,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${bookbox.books.length} ${localization.books}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Kanit',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Widget _buildBookboxesList(AppLocalizations localizations) {
    if (followedBookboxes == null || followedBookboxes!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show only the first 3 bookboxes (or less if there are fewer)
    final itemsToShow = followedBookboxes!.take(3).toList();

    int getCrossAxisCount() {
      if (itemsToShow.length == 1) return 1;
      if (itemsToShow.length == 2) return 2;
      return 3; 
    }

    double getAspectRatio() {
      final columnCount = getCrossAxisCount();
      if (columnCount == 1) return 2.5; 
      if (columnCount == 2) return 1.2; 
      return 0.85; 
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(),
        childAspectRatio: getAspectRatio(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: itemsToShow.length,
      itemBuilder: (context, index) {
        return _buildBookboxCard(itemsToShow[index], localizations);
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[400]!,
            Colors.grey[600]!,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.library_books,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

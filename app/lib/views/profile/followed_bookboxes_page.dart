import 'package:Lino_app/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/models/user_model.dart';
import 'package:Lino_app/services/bookbox_services.dart';
import 'package:Lino_app/utils/constants/routes.dart';

class FollowedBookboxesPage extends StatefulWidget {
  const FollowedBookboxesPage({super.key});

  @override
  _FollowedBookboxesPageState createState() => _FollowedBookboxesPageState();
}

class _FollowedBookboxesPageState extends State<FollowedBookboxesPage> {
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

      final user = await UserService().getUser(token);

      final bookboxes = await BookboxService().getFollowedBookboxes(
        token,
        user.followedBookboxes,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followed BookBoxes'),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading followed bookboxes',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadFollowedBookboxes,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (followedBookboxes == null || followedBookboxes!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'No followed bookboxes',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Kanit',
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start following bookboxes to see them here!',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: followedBookboxes!.length,
        itemBuilder: (context, index) {
          return _buildBookboxCard(followedBookboxes![index]);
        },
      ),
    );
  }

  Widget _buildBookboxCard(BookBox bookbox) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BookBox Image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                  ),
                  child: bookbox.image != null && bookbox.image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
              
              const SizedBox(height: 12),
              
              // BookBox Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        bookbox.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.book,
                            size: 16,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${bookbox.books.length} books',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ],
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

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
          size: 32,
        ),
      ),
    );
  }
}

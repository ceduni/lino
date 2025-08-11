import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/pages/bookbox/book_box_issue_report_page.dart';
import 'package:Lino_app/services/bookbox_services.dart';
import 'package:Lino_app/services/bookbox_state_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:timeago/timeago.dart' as timeago;

class BookBoxScreen extends StatefulWidget {
  const BookBoxScreen({super.key});

  @override
  State<BookBoxScreen> createState() => _BookBoxScreenState();
}

class _BookBoxScreenState extends State<BookBoxScreen> {
  final BookBoxStateService _stateService = Get.find<BookBoxStateService>();
  Future<BookBox>? _bookBoxDataFuture;
  String? bookBoxId;
  bool canInteract = false;
  String? token;
  bool isFollowed = false;
  bool isCheckingFollowStatus = false;

  @override
  void initState() {
    super.initState();
    
    // Get arguments from route
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      bookBoxId = arguments['bookboxId'] as String?;
      canInteract = arguments['canInteract'] as bool? ?? false;
    }
    
    if (bookBoxId != null) {
      _loadBookBoxData();
      _checkAuthAndFollowStatus();
      
      // Listen for refresh triggers
      _stateService.listenToRefresh(() {
        if (mounted) {
          _loadBookBoxData();
        }
      });
    }
  }

  Future<void> _checkAuthAndFollowStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
      
      if (token != null && bookBoxId != null) {
        setState(() {
          isCheckingFollowStatus = true;
        });
        
        final followed = await BookboxService().isBookboxFollowed(token!, bookBoxId!);
        
        setState(() {
          isFollowed = followed;
          isCheckingFollowStatus = false;
        });
      }
    } catch (e) {
      setState(() {
        isCheckingFollowStatus = false;
      });
      print('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow() async {
    if (token == null || bookBoxId == null) return;
    
    try {
      if (isFollowed) {
        await BookboxService().unfollowBookBox(token!, bookBoxId!);
        Get.snackbar(
          'Unfollowed',
          'You have unfollowed this BookBox',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        await BookboxService().followBookBox(token!, bookBoxId!);
        Get.snackbar(
          'Following',
          'You are now following this BookBox',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      setState(() {
        isFollowed = !isFollowed;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to ${isFollowed ? 'unfollow' : 'follow'} BookBox: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _loadBookBoxData() {
    if (bookBoxId != null) {
      setState(() {
        _bookBoxDataFuture = _getBookBoxData(bookBoxId!);
      });
    }
  }

  Future<BookBox> _getBookBoxData(String bookBoxId) async {
    return await BookboxService().getBookBox(bookBoxId);
  }

  String _getTimeAgo(DateTime dateAdded) {
    return timeago.format(dateAdded, locale: 'en');
  }

  @override
  Widget build(BuildContext context) {
    if (bookBoxId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Text(
            'No bookbox ID provided',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 235, 1),
      appBar: AppBar(
        title: const Text(
          'BookBox Details',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(101, 67, 33, 1),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Issue report button
          IconButton(
            onPressed: () async {
              final result = await Get.to(() => BookBoxIssueReportPage(bookboxId: bookBoxId!));
              
              // Show success snackbar if issue was reported successfully
              if (result != null && result['success'] == true) {
                Get.snackbar(
                  'Success',
                  result['message'] ?? 'Issue reported successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            icon: const Icon(
              Icons.report_problem,
              color: Colors.white,
            ),
            tooltip: 'Report Issue',
          ),
          // Follow/Unfollow button (only show if user is authenticated)
          if (token != null)
            isCheckingFollowStatus
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: _toggleFollow,
                    icon: Icon(
                      isFollowed ? Icons.favorite : Icons.favorite_border,
                      color: isFollowed ? Colors.red : Colors.white,
                    ),
                    tooltip: isFollowed ? 'Unfollow BookBox' : 'Follow BookBox',
                  ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<BookBox>(
        future: _bookBoxDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(101, 67, 33, 1),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading bookbox data',
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Kanit',
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No bookbox data available',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Kanit',
                  color: Colors.grey,
                ),
              ),
            );
          }
          return _buildContent(context, snapshot.data!);
        },
      ),
    ));
  }

  Widget _buildContent(BuildContext context, BookBox bookBox) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Maintenance Banner (show when bookbox is inactive)
          if (!bookBox.isActive) _buildMaintenanceBanner(),
          
          // BookBox Info Card
          _buildBookBoxInfoCard(bookBox),
          
          const SizedBox(height: 20),
          
          // Action Buttons Row
          _buildActionButtons(bookBox),
          
          const SizedBox(height: 20),
          
          // Books Section
          _buildBooksSection(bookBox),
        ],
      ),
    );
  }

  Widget _buildMaintenanceBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border.all(color: Colors.orange.shade400, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.construction,
            color: Colors.orange.shade700,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Under Maintenance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kanit',
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This BookBox is temporarily deactivated for maintenance. You can view the books inside but cannot exchange books from it until it\'s reactivated.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Kanit',
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookBoxInfoCard(BookBox bookBox) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(250, 250, 240, 1),
              Color.fromRGBO(245, 245, 235, 1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BookBox Image
              if (bookBox.image != null && bookBox.image!.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      bookBox.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              
              // BookBox Name
              Text(
                bookBox.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kanit',
                  color: Color.fromRGBO(101, 67, 33, 1),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Location Info
              if (bookBox.infoText != null && bookBox.infoText!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(101, 67, 33, 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color.fromRGBO(101, 67, 33, 1),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bookBox.infoText!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Kanit',
                            color: Color.fromRGBO(101, 67, 33, 1),
                          ),
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

  Widget _buildActionButtons(BookBox bookBox) {
    List<Widget> buttons = [];
    
    // Get Directions button (only show if canInteract is false)
    if (!canInteract) {
      buttons.add(
        Expanded(
          child: _buildDirectionButton(LatLng(bookBox.latitude, bookBox.longitude)),
        ),
      );
    }
    
    // Add/Remove book buttons (only show if canInteract is true)
    if (canInteract) {
      buttons.addAll([
        Expanded(
          child: _buildAddBookButton(bookBox.isActive),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildRemoveBookButton(bookBox.isActive),
        ),
      ]);
    }
    
    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Row(children: buttons);
  }

  Widget _buildDirectionButton(LatLng location) {
    return ElevatedButton.icon(
      onPressed: () => _openGoogleMapsApp(location.latitude, location.longitude),
      icon: const Icon(Icons.directions, color: Colors.white),
      label: const Text(
        'Get Directions',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Kanit',
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(142, 199, 233, 1),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    );
  }

  Widget _buildAddBookButton(bool isActive) {
    return ElevatedButton.icon(
      onPressed: isActive ? () {
        // TODO: Add book functionality
        Get.snackbar(
          'Add Book',
          'Add book functionality will be implemented',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } : () {
        Get.snackbar(
          'BookBox Under Maintenance',
          'Cannot add books while BookBox is deactivated for maintenance',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      },
      icon: Icon(Icons.add, color: isActive ? Colors.white : Colors.grey.shade400),
      label: Text(
        'Add Book',
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade400,
          fontFamily: 'Kanit',
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.green.shade600 : Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isActive ? 3 : 1,
      ),
    );
  }

  Widget _buildRemoveBookButton(bool isActive) {
    return ElevatedButton.icon(
      onPressed: isActive ? () {
        // TODO: Remove book functionality
        Get.snackbar(
          'Take Book',
          'Remove book functionality will be implemented',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } : () {
        Get.snackbar(
          'BookBox Under Maintenance',
          'Cannot remove books while BookBox is deactivated for maintenance',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      },
      icon: Icon(Icons.remove, color: isActive ? Colors.white : Colors.grey.shade400),
      label: Text(
        'Take Book',
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade400,
          fontFamily: 'Kanit',
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.red.shade600 : Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isActive ? 3 : 1,
      ),
    );
  }

  Widget _buildBooksSection(BookBox bookBox) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromRGBO(242, 226, 196, 1),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.library_books,
                  color: Color.fromRGBO(101, 67, 33, 1),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Books in this BookBox',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kanit',
                    color: Color.fromRGBO(101, 67, 33, 1),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(101, 67, 33, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${bookBox.books.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kanit',
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (bookBox.books.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No books available',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Kanit',
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to add a book to this BookBox!',
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: bookBox.books.length,
                itemBuilder: (context, index) {
                  return _buildBookCard(bookBox.books[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(book) {
    String title = book.title ?? 'Unknown Title';
    List<String> authors = book.authors ?? [];
    String authorsString = authors.isNotEmpty ? authors.join(', ') : 'Unknown Author';
    String timeAgo = _getTimeAgo(book.dateAdded);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to book details
          Get.snackbar(
            'Book Details',
            'Opening details for: $title',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.grey[300],
                  ),
                  child: book.coverImage != null && book.coverImage!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            book.coverImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildBookPlaceholder(title);
                            },
                          ),
                        )
                      : _buildBookPlaceholder(title),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Book Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kanit',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      authorsString,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontFamily: 'Kanit',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(101, 67, 33, 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Added $timeAgo',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color.fromRGBO(101, 67, 33, 1),
                          fontFamily: 'Kanit',
                        ),
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

  Widget _buildBookPlaceholder(String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[400]!,
            Colors.grey[600]!,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Future<void> _openGoogleMapsApp(double latitude, double longitude) async {
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';

    try {
      if (await canLaunchUrlString(googleMapsUrl)) {
        await launchUrlString(googleMapsUrl);
      } else {
        throw 'Could not open the map.';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open Google Maps',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

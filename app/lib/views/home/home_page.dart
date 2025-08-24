// app/lib/pages/home/home.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:Lino_app/vm/home/home_view_model.dart';
import 'package:Lino_app/vm/bookboxes/bookbox_list_view_model.dart';
import 'package:Lino_app/vm/map/map_view_model.dart';
import 'package:Lino_app/widgets/user_dashboard/profile_card_widget.dart';
import 'package:Lino_app/widgets/user_dashboard/ecological_impact_widget.dart';
import 'package:Lino_app/widgets/home_page.dart';
import 'package:Lino_app/widgets/recommendation_widget.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Notif> _notifications = [];
  bool _loadingNotifications = false;
  String? _notificationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<HomeViewModel>();
      viewModel.setContext(context);
      viewModel.initialize();
      viewModel.checkLocationPermission();
      
      final bookboxViewModel = context.read<BookboxListViewModel>();
      await bookboxViewModel.initialize();
      
      // Load notifications
      await _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loadingNotifications = true;
      _notificationError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        final userService = UserService();
        final notifications = await userService.getUserNotifications(token);
        setState(() {
          _notifications = notifications.take(3).toList(); // Show only the latest 3
          _loadingNotifications = false;
          print(notifications);
        });
      } else {
        setState(() {
          _loadingNotifications = false;
          _notificationError = 'No authentication token found';
        });
      }
    } catch (e) {
      setState(() {
        _loadingNotifications = false;
        _notificationError = 'Failed to load notifications: $e';
      });
      print('Error loading notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.isGuest) {
          return _buildGuestView(viewModel);
        }

        if (viewModel.isLoadingUser) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.error != null || viewModel.userData == null) {
          
          return Scaffold(
            body: Center(
              child: Text('Error loading user data: ${viewModel.error}'),
            ),
          );
        }
        
        return _buildAuthenticatedView(viewModel);
      },
    );
  }

  Widget _buildGuestView(HomeViewModel viewModel) {
    return Scaffold(
      body: Column(
        children: [
          _buildGuestMessage(),
          Expanded(
            child: _buildMapSection(viewModel),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Get.toNamed(AppRoutes.qrScanner),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text(
              'Scan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAuthenticatedView(HomeViewModel viewModel) {
    return Consumer<BookboxListViewModel>(
      builder: (context, bookboxViewModel, child) {
        
        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      
                      MergedProfileStatsWidget(
                        userName: viewModel.userData!.username,
                        booksSaved: viewModel.userData!.numSavedBooks,
                        waterSaved: viewModel.userData!.ecologicalImpact.savedWater,
                        treesSaved: viewModel.userData!.ecologicalImpact.savedTrees,
                      ),
                      /*
                      RecommendationWidget(
                        recommendedBooks: [
                          RecommendedBook(title: "livre", coverImageUrl: "rien"),
                          RecommendedBook(title: "livre", coverImageUrl: "rien"),
                          RecommendedBook(title: "livre", coverImageUrl: "rien"),
                        ],
                      ), */
                      _buildNotificationsSection(),
                      Container(
                        height: 300,
                        margin: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildMap(viewModel),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Get.toNamed(AppRoutes.qrScanner),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text(
              'Scan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildGuestMessage() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(66, 119, 184, 1),
                Color.fromRGBO(52, 95, 147, 1),
              ],
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.person_outline,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              const Text(
                'Welcome, Guest!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Kanit',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You\'re browsing as a guest. Sign in to unlock personalized features and start tracking your reading journey!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontFamily: 'Kanit',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color.fromRGBO(66, 119, 184, 1),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kanit',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection(HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildMap(viewModel),
        ),
      ),
    );
  }

  Widget _buildMap(HomeViewModel viewModel) {
    return Consumer2<BookboxListViewModel, MapViewModel>(
      builder: (context, bookboxViewModel, mapViewModel, child) {
        final markers = viewModel.getMarkers();

        return GoogleMap(
          onMapCreated: mapViewModel.onMapCreated,
          initialCameraPosition: mapViewModel.cameraPosition,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: Set<Marker>.of(markers),
        );
      },
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kanit',
                    ),
                  ),
                  if (_loadingNotifications)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    TextButton(
                      onPressed: () => (),
                      child: const Text('View All'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_loadingNotifications)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_notificationError != null)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        _notificationError!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (_notifications.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(Icons.notifications_none, color: Colors.grey, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'No notifications yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _notifications.map((notification) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 1,
                      child: ListTile(
                        leading: Icon(
                          notification.isRead ? Icons.mail_outline : Icons.mail,
                          color: notification.isRead ? Colors.grey : Colors.blue,
                        ),
                        title: Text(
                          notification.bookTitle,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (notification.reason.isNotEmpty)
                              Text(
                                _formatNotificationReason(notification.reason),
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              _formatNotificationDate(notification.createdAt),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () {
                          print("notis todo");
                        },
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNotificationDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatNotificationReason(List<String> reasons) {
    if (reasons.isEmpty) {
      return 'New notification';
    }

    List<String> formattedReasons = [];
    
    for (String reason in reasons) {
      switch (reason) {
        case 'book_request':
          formattedReasons.add('Someone requested this book');
          break;
        case 'solved_book_request':
          formattedReasons.add('Matches your book request');
          break;
        case 'fav_bookbox':
          formattedReasons.add('Added to followed bookbox');
          break;
        case 'same_borough':
          formattedReasons.add('Added near you');
          break;
        case 'fav_genre':
          formattedReasons.add('Matches your favorite genre');
          break;
        default:
          formattedReasons.add(reason); 
      }
    }

    if (formattedReasons.length == 1) {
      return formattedReasons[0];
    } else if (formattedReasons.length == 2) {
      return '${formattedReasons[0]} • ${formattedReasons[1]}';
    } else {
      return '${formattedReasons[0]} • ${formattedReasons[1]} • +${formattedReasons.length - 2} more';
    }
  }
}

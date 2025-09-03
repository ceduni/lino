// app/lib/pages/home/home.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:Lino_app/vm/home/home_view_model.dart';
import 'package:Lino_app/vm/bookboxes/bookbox_list_view_model.dart';
import 'package:Lino_app/vm/map/map_view_model.dart';
import 'package:Lino_app/widgets/home_page.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/models/notification_model.dart';
import 'package:Lino_app/views/profile/notifications_page.dart';
import 'package:Lino_app/vm/profile/notifications_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<Notif> _notifications = [];
  bool _loadingNotifications = false;
  String? _notificationError;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!mounted) return;
      
      try {
        final viewModel = context.read<HomeViewModel>();
        viewModel.setContext(context);
        viewModel.initialize();
        viewModel.checkLocationPermission();
        
        final bookboxViewModel = context.read<BookboxListViewModel>();
        await bookboxViewModel.initialize();
        
        if (mounted) {
          _hasInitialized = true;
          await _loadNotificationsWithRetry();
        }
      } catch (e) {
        print('Error during initialization: $e');
        if (mounted) {
          setState(() {
            _hasInitialized = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed && _hasInitialized && mounted) {
      _loadNotificationsWithRetry();
    }
  }

  Future<void> refreshNotifications() async {
    if (_hasInitialized && mounted) {
      await _loadNotificationsWithRetry();
    }
  }

  Future<void> _loadNotificationsWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _loadNotifications();
        if (_notificationError == null) {
          break; 
        }
      } catch (e) {
        print('Notification loading attempt $attempt failed: $e');
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    
    setState(() {
      _loadingNotifications = true;
      _notificationError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        final userService = UserService();
        
        final notifications = await userService.getUserNotifications(token)
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                throw Exception('Request timed out. Please check your connection.');
              },
            );
        
        if (mounted) {
          setState(() {
            _notifications = notifications.take(3).toList(); 
            _loadingNotifications = false;
            _notificationError = null;
          });
          print('Notifications loaded successfully: ${notifications.length} notifications');
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingNotifications = false;
            _notificationError = 'No authentication token found';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingNotifications = false;
          _notificationError = 'Failed to load notifications: $e';
        });
      }
      print('Error loading notifications: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (!mounted) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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
        if (!mounted) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
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
        if (!mounted) {
          return const Center(child: CircularProgressIndicator());
        }

        try {
          final markers = viewModel.getMarkers();

          return GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              if (mounted) {
                try {
                  mapViewModel.onMapCreated(controller);
                } catch (e) {
                  print('Error creating map: $e');
                }
              }
            },
            initialCameraPosition: mapViewModel.cameraPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: Set<Marker>.of(markers),
            gestureRecognizers: Set()
              ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
              ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
              ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
              ..add(Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer())),
          );
        } catch (e) {
          print('Error building map: $e');
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Map temporarily unavailable',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
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
                  Row(
                    children: [
                      if (_loadingNotifications)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else ...[
                        IconButton(
                          onPressed: () => _loadNotificationsWithRetry(),
                          icon: const Icon(Icons.refresh, size: 20),
                          tooltip: 'Refresh notifications',
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider(
                                create: (context) => NotificationsViewModel(),
                                child: const NotificationsPage(),
                              ),
                            ),
                          ),
                          child: const Text('View All'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_loadingNotifications)
                Column(
                  children: List.generate(3, (index) => 
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 1,
                      child: ListTile(
                        leading: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        title: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        subtitle: Container(
                          height: 12,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    )
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
                        'Unable to load notifications',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Check your internet connection and try again',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _loadNotificationsWithRetry(),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                        ),
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
                          _showNotificationDetails(context, notification);
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

  void _showNotificationDetails(BuildContext context, Notif notification) async {
    final List<String> reasons = notification.reason;

    String title;
    if (reasons.contains('book_request')) {
      title = 'Book Request';
    } else {
      title = 'New Book Available';
    }

    // Create a temporary view model to use its methods
    final tempViewModel = NotificationsViewModel();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: FutureBuilder<String>(
            future: tempViewModel.buildNotificationContent(notification),
            builder: (context, snapshot) {
              String content;
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = 'Loading...';
              } else if (snapshot.hasError) {
                content = tempViewModel.buildNotificationContentSync(notification);
              } else {
                content = snapshot.data ?? tempViewModel.buildNotificationContentSync(notification);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    content,
                    style: const TextStyle(
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    timeago.format(notification.createdAt),
                    style: const TextStyle(
                      fontSize: 10.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Mark the notification as read after closing the dialog
      _markNotificationAsRead(notification);
    });
  }

  Future<void> _markNotificationAsRead(Notif notification) async {
    if (!notification.isRead) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        
        if (token != null) {
          final userService = UserService();
          await userService.markNotificationAsRead(token, notification.id);
          // Refresh notifications to update the read status
          await _loadNotificationsWithRetry();
        }
      } catch (e) {
        print('Error marking notification as read: $e');
      }
    }
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

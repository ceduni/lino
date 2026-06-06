// app/lib/pages/home/home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lino_app/vm/home/home_view_model.dart';
import 'package:lino_app/vm/bookboxes/bookbox_list_view_model.dart';
import 'package:lino_app/views/home/home_guest_view.dart';
import 'package:lino_app/views/home/home_authenticated_view.dart';
import 'package:lino_app/services/user_services.dart';
import 'package:lino_app/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _hasInitialized && mounted) {
      _loadNotificationsWithRetry();
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

        final notifications = await userService.getUserNotifications(token).timeout(
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

        // Guest View
        if (viewModel.isGuest) {
          return HomeGuestView(viewModel: viewModel);
        }

        // Loading states for authenticated users
        if (viewModel.isLoadingUser || viewModel.isLoadingNews) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error state
        if (viewModel.error != null || viewModel.userData == null) {
          return Scaffold(
            body: Center(
              child: Text('Error loading user data: ${viewModel.error}'),
            ),
          );
        }

        // Authenticated View
        return HomeAuthenticatedView(
          viewModel: viewModel,
          notifications: _notifications,
          loadingNotifications: _loadingNotifications,
          notificationError: _notificationError,
          onRefreshNotifications: () => _loadNotificationsWithRetry(),
          onNotificationRead: () => _loadNotificationsWithRetry(),
        );
      },
    );
  }
}
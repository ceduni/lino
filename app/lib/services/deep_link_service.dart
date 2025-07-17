import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class DeepLinkService {
  static final _appLinks = AppLinks();
  static bool _initialized = false;
  static StreamSubscription<Uri>? _linkSubscription;
  
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    
    try {
      // Handle app launch from link
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        // Delay initial link handling to ensure app is fully initialized
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleDeepLink(initialUri);
        });
      }
      
      // Handle app already running
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          _handleDeepLink(uri);
        },
        onError: (error) {
          if (kDebugMode) {
            print('Deep link error: $error');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize deep links: $e');
      }
    }
  }
  
  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _initialized = false;
  }
  
  static void _handleDeepLink(Uri uri) {
    if (kDebugMode) {
      print('Deep link received: $uri');
    }
    
    try {
      // Parse the URL
      final segments = uri.pathSegments;
      
      if (segments.isNotEmpty && segments[0] == 'bookbox') {
        if (segments.length >= 2) {
          final bookboxId = segments[1];
          _navigateToBookbox(bookboxId);
        } else {
          _navigateToHome();
        }
      } else {
        // Default to home page
        _navigateToHome();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling deep link: $e');
      }
      _navigateToHome();
    }
  }
  
  static void _navigateToBookbox(String bookboxId) {
    if (kDebugMode) {
      print('Navigating to bookbox: $bookboxId');
    }
    
    try {
      // Ensure we're on the main thread and GetX is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          // Navigate to home first, then to bookbox
          Get.offAllNamed(AppRoutes.home);
          
          // Wait for navigation to complete before navigating to bookbox
          Future.delayed(const Duration(milliseconds: 300), () {
            if (Get.context != null) {
              Get.toNamed(
                AppRoutes.bookbox, 
                arguments: {
                  'bookboxId': bookboxId, 
                  'canInteract': true
                }
              );
            }
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error navigating to bookbox: $e');
      }
      _navigateToHome();
    }
  }
   
  static void _navigateToHome() {
    if (kDebugMode) {
      print('Navigating to home');
    }
    
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          Get.offAllNamed(AppRoutes.home);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error navigating to home: $e');
      }
    }
  }
}

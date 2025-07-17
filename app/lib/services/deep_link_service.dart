import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:Lino_app/utils/constants/routes.dart';

class DeepLinkService {
  static final _appLinks = AppLinks();
  static bool _initialized = false;
  
  static void initialize() {
    if (_initialized) return;
    _initialized = true;
    
    // Handle app launch from link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
    
    // Handle app already running
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }
  
  static void _handleDeepLink(Uri uri) {
    print('Deep link received: $uri');
    
    // Parse the URL
    final segments = uri.pathSegments;
    
    if (segments.isNotEmpty && segments[0] == 'bookbox') {
      if (segments.length >= 2) {
        final bookboxId = segments[1];
        _navigateToBookbox(bookboxId);
      }
    } else {
      // Default to home page
      _navigateToHome();
    }
  }
  
  static void _navigateToBookbox(String bookboxId) {
    print('Navigating to bookbox: $bookboxId');
    
    // Navigate to home first, then to bookbox
    Get.offAllNamed(AppRoutes.home);
    
    // Then navigate to bookbox with ID
    // Use a delay to ensure home page is loaded first
    Future.delayed(Duration(milliseconds: 100), () {
      Get.toNamed(AppRoutes.bookbox, arguments: {'bookboxId': bookboxId, 'canInteract': true});
    });
  }
  
  static void _navigateToHome() {
    print('Navigating to home');
    Get.offAllNamed(AppRoutes.home);
  }
}
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Image Upload Configuration
// 
// This file contains configuration for the image upload service.
// The API credentials are now read from .env file for cross-platform compatibility

class ImageConfig {
  // Image Settings
  static const int maxImageWidth = 800;
  static const int maxImageHeight = 800;
  static const int imageQuality = 85; // 0-100, higher = better quality but larger file
  static const int maxFileSizeMB = 10; // Maximum file size in MB

  // Cloudflare Configuration
  static const String accountId = '18867c89dfbd402b3e2af59050d8caf6';

  /// Gets the Cloudflare API token from .env file
  static String getCloudflareApiToken() {
    return dotenv.env['CLOUDFLARE_API_TOKEN'] ?? 'YOUR_CLOUDFLARE_API_TOKEN_HERE';
  }

  /// Checks if Cloudflare is properly configured
  static bool isCloudflareConfigured() {
    final apiToken = getCloudflareApiToken();
    return apiToken != 'YOUR_CLOUDFLARE_API_TOKEN_HERE' && apiToken.isNotEmpty;
  }
}
import 'package:flutter/services.dart';

// Image Upload Configuration
// 
// This file contains configuration for the image upload service.
// The API key is now read from Android's BuildConfig (local.properties)

class ImageConfig {
  static const MethodChannel _channel = MethodChannel('com.example.test_app/config');
  
  // Cached API key
  static String? _cachedApiKey;
  
  // Image Settings
  static const int maxImageWidth = 800;
  static const int maxImageHeight = 800;
  static const int imageQuality = 85; // 0-100, higher = better quality but larger file
  static const int maxFileSizeMB = 10; // Maximum file size in MB
  
  /// Gets the ImgBB API key from Android BuildConfig
  /// Returns cached value if already retrieved
  static Future<String> getImgbbApiKey() async {
    if (_cachedApiKey != null) {
      return _cachedApiKey!;
    }
    
    try {
      final String apiKey = await _channel.invokeMethod('getImgbbApiKey');
      _cachedApiKey = apiKey;
      return apiKey;
    } on PlatformException catch (e) {
      print('Failed to get ImgBB API key: ${e.message}');
      return 'YOUR_IMGBB_API_KEY_HERE'; // Fallback
    }
  }
  
  /// Checks if ImgBB is properly configured
  static Future<bool> isImgbbConfigured() async {
    final apiKey = await getImgbbApiKey();
    return apiKey != 'YOUR_IMGBB_API_KEY_HERE' && apiKey.isNotEmpty;
  }
}

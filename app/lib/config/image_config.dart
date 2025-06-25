// Image Upload Configuration

class ImageConfig {
  static const String imgbbApiKey = '53ecd9cbf300fdf7b88d24bd0857bc92'; 
  
  // Image Settings
  static const int maxImageWidth = 800;
  static const int maxImageHeight = 800;
  static const int imageQuality = 75; // 0-100, higher = better quality but larger file
  static const int maxFileSizeMB = 10; // Maximum file size in MB
  
  // Validation
  static bool get isImgbbConfigured => imgbbApiKey != 'YOUR_IMGBB_API_KEY' && imgbbApiKey.isNotEmpty;
}

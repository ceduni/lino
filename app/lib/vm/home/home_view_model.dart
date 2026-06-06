import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:lino_app/models/bookbox_model.dart';
import 'package:lino_app/models/user_model.dart';
import 'package:lino_app/services/user_services.dart';
import 'package:lino_app/vm/bookboxes/bookbox_list_view_model.dart';
import 'package:lino_app/vm/map/map_view_model.dart';
import 'package:lino_app/nav_menu.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

// Model class
class NewsArticle {
  final String title;
  final String imageUrl;
  final String date;
  final String url;

  NewsArticle({
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.url,
  });
}

class HomeViewModel extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isInitialized = false;
  String? _token;
  User? _userData;
  bool _isLoadingUser = false;
  String? _error;
  int _clickCount = 0;

  // Context for accessing other ViewModels
  BuildContext? _context;

  bool get isInitialized => _isInitialized;
  String? get token => _token;
  User? get userData => _userData;
  bool get isLoadingUser => _isLoadingUser;
  String? get error => _error;

  List<NewsArticle> _montrealNews = [];
  bool _isLoadingNews = false;
  String? _newsError;

  List<NewsArticle> get montrealNews => _montrealNews;
  bool get isLoadingNews => _isLoadingNews;
  String? get newsError => _newsError;

  void setContext(BuildContext context) {
    _context = context;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _isInitialized = true;
      notifyListeners();

      if (_token != null && _token!.isNotEmpty) {
        await loadUserData();
      }

      await fetchMontrealNews();
    } catch (e) {
      _error = e.toString();
      _isInitialized = true;
      notifyListeners();
    }
  }



Future<void> fetchMontrealNews() async {
  _isLoadingNews = true;
  _newsError = null;
  notifyListeners();
  
  try {
    print('🔍 Fetching Montreal news about books...');
    
    final List<NewsArticle> allArticles = [];
    
    // Fetch multiple pages (up to 3 pages to get ~30 articles)
    for (int page = 1; page <= 3; page++) {
      final response = await http.get(
        Uri.parse('https://montreal.ca/nouvelles?q=livre&page=$page'),
      );

      print('📡 Page $page - Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('❌ Bad response status on page $page');
        break;
      }

      final document = html_parser.parse(response.body);
      
      // Sélectionner les articles de la liste
      final articleElements = document.querySelectorAll('li.list-group-item.list-element');
      
      print('📰 Page $page: Found ${articleElements.length} articles');
      
      if (articleElements.isEmpty) {
        print('No more articles found, stopping pagination');
        break;
      }
      
      for (var i = 0; i < articleElements.length; i++) {
        var element = articleElements[i];
        try {
          // Extract title
          final titleElement = element.querySelector('.list-group-item-title');
          final title = titleElement?.text.trim() ?? '';
          
          if (title.isEmpty) continue;
          
          print('  Article ${allArticles.length + 1}: ${title.length > 50 ? title.substring(0, 50) : title}...');
          
          // Extract image URL
          final imgElement = element.querySelector('.list-group-thumb img');
          String imageUrl = imgElement?.attributes['src'] ?? '';
          
          if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
            // Keep cloudinary URL as is
            if (!imageUrl.startsWith('https://')) {
              imageUrl = 'https://res.cloudinary.com$imageUrl';
            }
          }
          
          if (imageUrl.isEmpty) {
            imageUrl = 'https://picsum.photos/280/140?random=${allArticles.length}';
          }
          
          // Extract date
          final dateElements = element.querySelectorAll('.list-group-info-item');
          String dateStr = '';
          if (dateElements.isNotEmpty) {
            dateStr = dateElements.first.text.trim();
          }
          
          if (dateStr.isEmpty) {
            dateStr = _formatDate(DateTime.now());
          }
          
          // Extract article URL
          final linkElement = element.querySelector('a');
          String articleUrl = linkElement?.attributes['href'] ?? '';
          
          if (articleUrl.isNotEmpty && !articleUrl.startsWith('http')) {
            articleUrl = 'https://montreal.ca$articleUrl';
          }
          
          allArticles.add(NewsArticle(
            title: title,
            imageUrl: imageUrl,
            date: dateStr,
            url: articleUrl.isNotEmpty ? articleUrl : 'https://montreal.ca/nouvelles?q=livre',
          ));
          
        } catch (e) {
          print('❌ Error parsing article: $e');
          continue;
        }
      }
      
      // Stop if we have enough articles
      if (allArticles.length >= 10) break;
      
      // Add a small delay between requests to be polite
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    // Limit to 10 articles for display
    _montrealNews = allArticles.take(10).toList();
    
    print('✅ Total articles fetched: ${_montrealNews.length}');
    
    _isLoadingNews = false;
    notifyListeners();
    
  } catch (e) {
    print('❌ Error fetching Montreal news: $e');
    _newsError = e.toString();
    _montrealNews = [];
    _isLoadingNews = false;
    notifyListeners();
  }
}

String _formatDate(DateTime date) {
  final months = [
    'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
    'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}




  Future<void> loadUserData() async {
    if (_token == null) return;

    _isLoadingUser = true;
    _error = null;
    notifyListeners();

    try {
      _userData = await UserService().getUser(_token!);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _userData = null;
    }

    _isLoadingUser = false;
    notifyListeners();
  }

  Future<void> checkLocationPermission() async {
    if (_context == null) return;

    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    if (status.isGranted) {
      final bookboxViewModel = Provider.of<BookboxListViewModel>(_context!, listen: false);
      await bookboxViewModel.refreshBookboxes();
    }
  }

  String getSnippet(ShortenedBookBox bbox) {
    if (!bbox.isActive) {
      return 'This book box is currently inactive.';
    }

    if (_context != null) {
      final bookboxViewModel = Provider.of<BookboxListViewModel>(_context!, listen: false);
      if (bookboxViewModel.userPosition != null) {
        final distance = Geolocator.distanceBetween(
              bookboxViewModel.userPosition!.latitude,
              bookboxViewModel.userPosition!.longitude,
              bbox.latitude,
              bbox.longitude,
            ) /
            1000;
        return 'Distance: ${distance.toStringAsFixed(2)} km';
      }
    }

    return '${bbox.booksCount} books available';
  }

  List<Marker> getMarkers() {
    if (_context == null) return [];

    final bookboxViewModel = Provider.of<BookboxListViewModel>(_context!, listen: false);
    final bboxes = bookboxViewModel.bookboxes;

    return bboxes
        .map((bbox) => Marker(
              markerId: MarkerId(bbox.id),
              position: LatLng(bbox.latitude, bbox.longitude),
              infoWindow: InfoWindow(
                title: bbox.name,
                snippet: getSnippet(bbox),
              ),
              icon: bbox.isActive
                  ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
                  : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              onTap: () {
                bookboxViewModel.highlightBookbox(bbox.id);
              },
            ))
        .toList();
  }

  // Helper methods for accessing ViewModels
  BookboxListViewModel? getBookboxViewModel() {
    if (_context == null) return null;
    return Provider.of<BookboxListViewModel>(_context!, listen: false);
  }

  MapViewModel? getMapViewModel() {
    if (_context == null) return null;
    return Provider.of<MapViewModel>(_context!, listen: false);
  }

  void navigateToProfile() {
    final NavigationController navController = Get.find<NavigationController>();
    navController.selectedIndex.value = 3; // Profile page
    navController.update();
  }

  Future<void> handleEasterEggClick() async {
    _clickCount++;
    print('Click count: $_clickCount');

    if (_clickCount >= 5) {
      try {
        await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
        _clickCount = 0; // Reset counter after playing sound
        print('Easter egg activated!');
      } catch (e) {
        print('Error playing sound: $e');
      }
    }
  }

  bool get isGuest => _token == null || _token!.isEmpty;
}

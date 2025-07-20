import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/user_model.dart';
import '../../services/user_services.dart';
import '../../widgets/home_profile_summary.dart';
import '../map/book_box_controller.dart';

class HomePage extends HookWidget {
  final BookBoxController bookBoxController = Get.put(BookBoxController());

  Future<String?> initializePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<User> getUserData(String token) async {
    return await UserService().getUser(token);
  }

  Future<void> _checkLocationPermission(BuildContext context) async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    if (status.isGranted) {
      bookBoxController.getUserLocation();
    }
  }


  Widget buildMapSection() {
    return Obx(() {
      final bboxes = bookBoxController.bookBoxes;
      
      List<Marker> markers = bboxes
          .map((bbox) => Marker(
                markerId: MarkerId(bbox.id),
                position: LatLng(bbox.latitude, bbox.longitude),
                infoWindow: InfoWindow(
                  title: bbox.name,
                  snippet: bbox.infoText ?? '',
                ),
                icon: BitmapDescriptor.defaultMarker,
                onTap: () {
                  bookBoxController.highlightBookBox(bbox.id);
                },
              ))
          .toList();

      return GoogleMap(
        onMapCreated: bookBoxController.mapController.onMapCreated,
        initialCameraPosition: bookBoxController.mapController.cameraPosition.value,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: Set<Marker>.of(markers),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final initialized = useState(false);
    final token = useState<String?>(null);
    final clicks = useState(0);
    final audioPlayer = useMemoized(() => AudioPlayer(), []);

    useEffect(() {
      initializePrefs().then((value) {
        token.value = value;
        initialized.value = true;
      });
      _checkLocationPermission(context);
      return null;
    }, []);

    Future<void> addClick() async {
      clicks.value++;
      print('Click count: ${clicks.value}');
      if (clicks.value >= 5) {
        try {
          await audioPlayer.play(AssetSource('sounds/beep.mp3'));
          clicks.value = 0; // Reset counter after playing sound
          print('hmmmmmmmmmmmmmmm');
        } catch (e) {
          print('Error playing sound: $e');
        }
      }
    }

    if (!initialized.value) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (token.value == null || token.value!.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            // Guest message
            Container(
              padding: EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.person_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Welcome, Guest!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Please log in to see your profile',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Map section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: buildMapSection(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final userData = useFuture(useMemoized(() => getUserData(token.value!), [token.value]));
    //print('boop ${userData.data?.ecologicalImpact.carbonSavings}');
    
    

    if (userData.connectionState != ConnectionState.done) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData.hasError || userData.data == null) {
      return Scaffold(
        body: Center(child: Text('Error loading user data')),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Profile summary section
          HomeProfileSummary(
            username: userData.data!.username,
            numSavedBooks: userData.data!.numSavedBooks,
            savedTrees: userData.data!.ecologicalImpact.savedTrees,
            carbonSavings: userData.data!.ecologicalImpact.carbonSavings,
            onTap: () {
              addClick();
            },
          ),
          // Map section
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: buildMapSection(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
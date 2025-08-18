// app/lib/pages/home/home.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/home/home_view_model.dart';
import 'package:Lino_app/vm/bookboxes/bookbox_list_view_model.dart';
import 'package:Lino_app/vm/map/map_view_model.dart';
import 'package:Lino_app/widgets/user_dashboard/profile_card_widget.dart';
import 'package:Lino_app/widgets/user_dashboard/ecological_impact_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<HomeViewModel>();
      viewModel.setContext(context);
      viewModel.initialize();
      viewModel.checkLocationPermission();
      
      // Initialize bookbox data
      final bookboxViewModel = context.read<BookboxListViewModel>();
      bookboxViewModel.initialize();
    });
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
    );
  }

  Widget _buildAuthenticatedView(HomeViewModel viewModel) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ProfileCard(
                    user: viewModel.userData!,
                    includeModifyButton: true,
                  ),
                  EcologicalImpactCard(
                    user: viewModel.userData!,
                  ),
                  // Action buttons section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Scan Bookbox - full width
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => print("scan bookbox"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              "Scan Bookbox",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Add Book and Take Book - half width each
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => print("add book"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  "Add Book",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => print("take book"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child: const Text(
                                  "Take Book",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
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
}

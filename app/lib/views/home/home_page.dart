// app/lib/pages/home/home.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/home/home_view_model.dart';
import 'package:Lino_app/widgets/home_profile_summary.dart';

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
      viewModel.initialize();
      viewModel.checkLocationPermission();
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
          HomeProfileSummary(
            user: viewModel.userData!,
            numSavedBooks: viewModel.userData!.numSavedBooks,
            savedTrees: viewModel.userData!.ecologicalImpact.savedTrees,
            carbonSavings: viewModel.userData!.ecologicalImpact.carbonSavings,
            onTap: viewModel.navigateToProfile,
          ),
          Expanded(
            child: _buildMapSection(viewModel),
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
    return StreamBuilder<Object>(
      stream: viewModel.bookBoxController.bookBoxes.stream,
      builder: (context, snapshot) {
        final markers = viewModel.getMarkers();

        return GoogleMap(
          onMapCreated: viewModel.bookBoxController.mapController.onMapCreated,
          initialCameraPosition: viewModel.bookBoxController.mapController.cameraPosition.value,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: Set<Marker>.of(markers),
        );
      },
    );
  }
}
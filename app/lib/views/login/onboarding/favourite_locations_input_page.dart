// app/lib/views/login/onboarding/favourite_locations_input_page.dart
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/login/onboarding/favourite_locations_input_view_model.dart';

class FavouriteLocationsInputPage extends StatefulWidget {

  const FavouriteLocationsInputPage({super.key});

  @override
  State<FavouriteLocationsInputPage> createState() => _FavouriteLocationsInputPageState();
}

class _FavouriteLocationsInputPageState extends State<FavouriteLocationsInputPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavouriteLocationsInputViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4277B8),
      body: Consumer<FavouriteLocationsInputViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(viewModel),
                _buildMap(viewModel),
                _buildBottomSection(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(FavouriteLocationsInputViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text(
            'Set Your Favourite Locations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Add places you visit often to get personalized book recommendations',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildSearchBar(viewModel),
        ],
      ),
    );
  }

  Widget _buildSearchBar(FavouriteLocationsInputViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: viewModel.searchController,
        googleAPIKey: viewModel.googleApiKey,
        inputDecoration: InputDecoration(
          hintText: 'Search for places...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF4277B8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        debounceTime: 600,
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          viewModel.onPlaceSelected(prediction);
        },
        itemClick: (Prediction prediction) {
          viewModel.searchController.text = prediction.description!;
          viewModel.searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: prediction.description!.length),
          );
        },
      ),
    );
  }

  Widget _buildMap(FavouriteLocationsInputViewModel viewModel) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                viewModel.setMapController(controller);
              },
              initialCameraPosition: CameraPosition(
                target: viewModel.currentLocation,
                zoom: 12.0,
              ),
              markers: viewModel.markers,
              onTap: (position) => viewModel.onMapTap(position),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
            if (viewModel.isAddingLocation)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            _buildInstructionsOverlay(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsOverlay(FavouriteLocationsInputViewModel viewModel) {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Tap anywhere on the map to add a location (${viewModel.favouriteLocations.length}/10)',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBottomSection(FavouriteLocationsInputViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          if (viewModel.favouriteLocations.isNotEmpty) _buildLocationCounter(viewModel),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildLocationCounter(FavouriteLocationsInputViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            '${viewModel.favouriteLocations.length} location${viewModel.favouriteLocations.length == 1 ? '' : 's'} added',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Get.offNamed(AppRoutes.home),
          child: const Text(
            'Skip',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: () => Get.offNamed(AppRoutes.home),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF4277B8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: const Text(
            'Continue',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
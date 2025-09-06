// app/lib/views/favourite_locations_page.dart
import 'package:Lino_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:Lino_app/vm/profile/options/favourite_locations_view_model.dart';
import 'package:Lino_app/utils/constants/colors.dart';

class FavouriteLocationsPage extends StatefulWidget {
  const FavouriteLocationsPage({super.key});

  @override
  State<FavouriteLocationsPage> createState() => _FavouriteLocationsPageState();
}

class _FavouriteLocationsPageState extends State<FavouriteLocationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<FavouriteLocationsViewModel>();
      viewModel.onMarkerTap = _showRemoveLocationDialog;
      viewModel.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Locations'),
        backgroundColor: LinoColors.secondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Consumer<FavouriteLocationsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Column(
              children: [
                _buildSearchBar(viewModel),
                _buildMap(viewModel),
                _buildResizableDivider(viewModel),
                _buildLocationsList(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(FavouriteLocationsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: viewModel.searchController,
        googleAPIKey: viewModel.googleApiKey,
        inputDecoration: InputDecoration(
          hintText: 'Search for places...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[100],
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

  Widget _buildMap(FavouriteLocationsViewModel viewModel) {
    return Expanded(
      flex: viewModel.mapFlex.round(),
      child: Stack(
        children: [
          GoogleMap(
            onMapCreated: viewModel.setMapController,
            initialCameraPosition: CameraPosition(
              target: viewModel.currentLocation,
              zoom: 12.0,
            ),
            markers: viewModel.markers,
            onTap: viewModel.onMapTap,
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
        ],
      ),
    );
  }

  Widget _buildResizableDivider(FavouriteLocationsViewModel viewModel) {
    return GestureDetector(
      onPanStart: (details) => viewModel.setDragging(true),
      onPanUpdate: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final screenHeight = renderBox.size.height;
        final appBarHeight = AppBar().preferredSize.height;
        const searchBarHeight = 80.0;
        const dividerHeight = 20.0;
        final availableHeight = screenHeight - appBarHeight - searchBarHeight - dividerHeight - MediaQuery.of(context).padding.top;

        final dragPosition = details.globalPosition.dy - appBarHeight - searchBarHeight - MediaQuery.of(context).padding.top;
        viewModel.updateDividerPosition(dragPosition, availableHeight);
      },
      onPanEnd: (details) => viewModel.setDragging(false),
      child: Container(
        height: 20,
        decoration: BoxDecoration(
          color: viewModel.isDragging ? LinoColors.secondary.withValues(alpha: 0.3) : Colors.grey[200],
          border: Border.symmetric(
            horizontal: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: viewModel.isDragging ? LinoColors.secondary : Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationsList(FavouriteLocationsViewModel viewModel) {
    return Expanded(
      flex: viewModel.listFlex.round(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border(
            top: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildListHeader(viewModel),
              _buildLocationItems(viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader(FavouriteLocationsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Favourite Locations (${viewModel.favouriteLocations.length}/10)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (viewModel.favouriteLocations.isNotEmpty)
            TextButton(
              onPressed: () => _showClearAllDialog(viewModel),
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationItems(FavouriteLocationsViewModel viewModel) {
    return Expanded(
      child: viewModel.favouriteLocations.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No favourite locations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap on the map or search to add locations',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: viewModel.favouriteLocations.length,
        itemBuilder: (context, index) {
          final location = viewModel.favouriteLocations[index];
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: ListTile(
              leading: const Icon(
                Icons.location_on,
                color: Colors.red,
              ),
              title: Text(
                location.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showRemoveLocationDialog(location),
              ),
              onTap: () => viewModel.centerMapOnLocation(location),
            ),
          );
        },
      ),
    );
  }

  void _showRemoveLocationDialog(FavouriteLocation location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Location'),
          content: Text('Remove "${location.name}" from your favourite locations?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                context.read<FavouriteLocationsViewModel>().removeFavouriteLocation(location);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to use'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Search for places using the search bar'),
              SizedBox(height: 8),
              Text('• Tap anywhere on the map to add a location'),
              SizedBox(height: 8),
              Text('• Tap on markers to remove locations'),
              SizedBox(height: 8),
              Text('• Drag the divider between map and list to resize'),
              SizedBox(height: 8),
              Text('• Maximum 10 favourite locations allowed'),
              SizedBox(height: 8),
              Text('• Tap on list items to center map on location'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDialog(FavouriteLocationsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Locations'),
          content: const Text('Are you sure you want to remove all favourite locations?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                viewModel.clearAllLocations();
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
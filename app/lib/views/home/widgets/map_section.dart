// app/lib/widgets/home/map_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:lino/vm/home/home_view_model.dart';
import 'package:lino/vm/bookboxes/bookbox_list_view_model.dart';
import 'package:lino/vm/map/map_view_model.dart';
import 'package:lino/l10n/app_localizations.dart';

class MapWidget extends StatelessWidget {
  final HomeViewModel viewModel;
  final AppLocalizations localizations;
  final bool showCard;

  const MapWidget({
    super.key,
    required this.viewModel,
    required this.localizations,
    this.showCard = true,
  });

  @override
  Widget build(BuildContext context) {
    if (showCard) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildMapContent(context),
        ),
      );
    }
    
    return _buildMapContent(context);
  }

  Widget _buildMapContent(BuildContext context) {
    return Consumer2<BookboxListViewModel, MapViewModel>(
      builder: (context, bookboxViewModel, mapViewModel, child) {
        try {
          final markers = viewModel.getMarkers();

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  try {
                    mapViewModel.onMapCreated(controller);
                  } catch (e) {
                    print('Error creating map: $e');
                  }
                },
                initialCameraPosition: mapViewModel.cameraPosition,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: Set<Marker>.of(markers),
                gestureRecognizers: Set()
                  ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
                  ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
                  ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
                  ..add(Factory<VerticalDragGestureRecognizer>(
                      () => VerticalDragGestureRecognizer())),
              ),
            ],
          );
        } catch (e) {
          print('Error building map: $e');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  localizations.mapTemporarilyUnavailable,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

/// A version of the map widget with padding and card styling for the guest view
class MapSectionWidget extends StatelessWidget {
  final HomeViewModel viewModel;
  final AppLocalizations localizations;

  const MapSectionWidget({
    super.key,
    required this.viewModel,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 24.0),
      child: MapWidget(
        viewModel: viewModel,
        localizations: localizations,
        showCard: true,
      ),
    );
  }
}
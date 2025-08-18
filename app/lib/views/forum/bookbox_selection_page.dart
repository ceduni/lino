import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:Lino_app/vm/forum/bookbox_selection_view_model.dart';
import 'package:Lino_app/vm/forum/requests_view_model.dart';
import 'package:Lino_app/widgets/bookbox_map_widget.dart';

class BookboxSelectionPage extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const BookboxSelectionPage({
    required this.arguments,
    super.key,
  });

  @override
  State<BookboxSelectionPage> createState() => _BookboxSelectionPageState();
}

class _BookboxSelectionPageState extends State<BookboxSelectionPage> {
  late BookboxSelectionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BookboxSelectionViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.initialize(widget.arguments);
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<BookboxSelectionViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: const Color.fromRGBO(245, 245, 235, 1),
            appBar: AppBar(
              title: const Text(
                'Select Bookboxes',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color.fromRGBO(101, 67, 33, 1),
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            body: Column(
              children: [
                // Header section with book info and instructions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book title
                      Text(
                        'Requesting: ${viewModel.title}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit',
                          color: Color.fromRGBO(101, 67, 33, 1),
                        ),
                      ),
                      
                      // Selected book info if available
                      if (viewModel.selectedSuggestion != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'by ${viewModel.selectedSuggestion!.author}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 12),
                      
                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Select bookboxes where you\'d like this book to be added. Tap on map pins to select/deselect them.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Selection counter
                      const SizedBox(height: 8),
                      Text(
                        '${viewModel.selectedBookboxIds.length} bookbox${viewModel.selectedBookboxIds.length == 1 ? '' : 'es'} selected',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: viewModel.selectedBookboxIds.isEmpty 
                              ? Colors.grey[600] 
                              : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Map section
                Expanded(
                  flex: 3, // Limit the map to take up less space
                  child: viewModel.isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.fromRGBO(101, 67, 33, 1),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading nearby bookboxes...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Kanit',
                                ),
                              ),
                            ],
                          ),
                        )
                      : viewModel.error != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error Loading Bookboxes',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      viewModel.error!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: viewModel.retry,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(101, 67, 33, 1),
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : viewModel.bookboxes.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
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
                                          'No Bookboxes Found',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'No bookboxes were found in your area. Try expanding your search radius.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : BookboxMapWidget(
                                  bookboxes: viewModel.bookboxes,
                                  onSelectionChanged: viewModel.onSelectionChanged,
                                  initialLocation: viewModel.initialLocation,
                                ),
                ),
                
                // Bottom section with error message and create button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0), // Extra bottom padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                    children: [
                      // Error message
                      if (viewModel.error != null && !viewModel.isLoading)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.error!,
                                  style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: viewModel.clearError,
                                child: const Text('Dismiss'),
                              ),
                            ],
                          ),
                        ),
                      
                      // Create Request Button
                      SizedBox(
                        width: double.infinity,
                        child: viewModel.isSubmitting
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromRGBO(101, 67, 33, 1),
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: viewModel.selectedBookboxIds.isEmpty
                                    ? null
                                    : () => _createRequest(viewModel),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(101, 67, 33, 1),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  disabledForegroundColor: Colors.grey.shade600,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  viewModel.selectedBookboxIds.isEmpty
                                      ? 'Select at least one bookbox'
                                      : 'Create Request (${viewModel.selectedBookboxIds.length} selected)',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Kanit',
                                  ),
                                ),
                              ),
                      ),
                    ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _createRequest(BookboxSelectionViewModel viewModel) async {
    final success = await viewModel.createRequest();
    
    if (success && mounted) {
      // Refresh the requests list if available
      try {
        context.read<RequestsViewModel>().refresh();
      } catch (e) {
        // RequestsViewModel might not be available in this context
      }
      
      // Navigate back to the forum screen (pop twice to go back to forum)
      Get.back(); // Pop bookbox selection page
      Get.back(); // Pop request form page
      
      Get.snackbar(
        'Success',
        'Request created successfully! 📚\n${viewModel.selectedBookboxIds.length} bookbox${viewModel.selectedBookboxIds.length == 1 ? '' : 'es'} selected.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
      );
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Request created successfully! 📚\n${viewModel.selectedBookboxIds.length} bookbox${viewModel.selectedBookboxIds.length == 1 ? '' : 'es'} selected.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );*/
    }
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:Lino_app/services/bookbox_services.dart';

class BarcodeScannerViewModel extends ChangeNotifier {
  // State variables
  bool _isScanning = true;
  bool _showFallback = false;
  EditableBook? _scannedBook;
  String? _error;
  Timer? _timeoutTimer;
  bool _shouldRestartCamera = false;
  
  // Parameters for different behavior
  bool? _addingBook;
  String? _bookboxId;
  
  // Getters
  bool get isScanning => _isScanning;
  bool get showFallback => _showFallback;
  EditableBook? get scannedBook => _scannedBook;
  String? get error => _error;
  bool get shouldRestartCamera => _shouldRestartCamera;
  
  // Method to set parameters and initialize fresh state
  void setParameters(bool addingBook, String bookboxId) {
    // Always cancel any existing timer first
    _timeoutTimer?.cancel();
    
    // Set parameters
    _addingBook = addingBook;
    _bookboxId = bookboxId;
    
    // Reset all state when parameters are set (new page visit)
    _resetToInitialState();
  }
  
  void _resetToInitialState() {
    _timeoutTimer?.cancel();
    _isScanning = true;
    _showFallback = false;
    _scannedBook = null;
    _error = null;
    _shouldRestartCamera = false;
    // Don't reset _addingBook and _bookboxId here as they're set by setParameters
    notifyListeners();
  }
  
  void startScanning() {
    _isScanning = true;
    _showFallback = false;
    _scannedBook = null;
    _error = null;
    notifyListeners();
    
    // Start 5-second timeout
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (_scannedBook == null && _isScanning) {
        _showFallbackUI();
      }
    });
  }
  
  Future<void> onBarcodeDetected(String barcode) async {
    if (!_isScanning || _scannedBook != null) return;
    
    // Safety check: ensure parameters are set
    if (_addingBook == null || _bookboxId == null) {
      debugPrint('Warning: BarcodeScannerViewModel parameters not set properly');
      return;
    }
    
    // Cancel timeout since we got a barcode
    _timeoutTimer?.cancel();
    
    try {
      // Validate that it's a potential ISBN (10 or 13 digits)
      final cleanBarcode = barcode.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanBarcode.length != 10 && cleanBarcode.length != 13) {
        // Invalid ISBN format, continue scanning
        _restartTimeout();
        return;
      }
      
      _error = null;
      notifyListeners();
      
      EditableBook? book;
      
      // Different behavior based on addingBook parameter
      if (_addingBook == false && _bookboxId != null) {
        // When taking a book, first try to find it in the bookbox
        final foundBook = await BookboxService().tryFindBookInBookBox(_bookboxId!, barcode);
        if (foundBook != null) {
          // Convert Book to EditableBook using factory function
          book = EditableBook.fromBook(foundBook);
        } else {
          // If not found in bookbox when taking, show error
          _error = "This book is not available in this BookBox. Please scan a book that is currently in the BookBox.";
          _isScanning = false;
          notifyListeners();
          return;
        }
      } else {
        // For adding books or when bookboxId is null, use API directly
        book = await BookService().getBookInfo(barcode);
      }
      
      _scannedBook = book;
      _isScanning = false;
      _showFallback = false;
      notifyListeners();
      
    } catch (e) {
      // If book not found in API, continue scanning (don't show error immediately)
      _error = null;
      // Don't stop scanning, let the timeout handle showing fallback
      _restartTimeout();
    }
  }
  
  void _restartTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (_scannedBook == null && _isScanning) {
        _showFallbackUI();
      }
    });
  }
  
  void _showFallbackUI() {
    _showFallback = true;
    // Keep scanning active even when showing fallback
    _isScanning = true;
    notifyListeners();
  }
  
  void resetScanner() {
    _timeoutTimer?.cancel();
    _isScanning = true;
    _showFallback = false;
    _scannedBook = null;
    _error = null;
    
    // Signal that camera needs to be restarted (iOS fix)
    _shouldRestartCamera = true;
    notifyListeners();
    
    // Restart timeout
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (_scannedBook == null && _isScanning) {
        _showFallbackUI();
      }
    });
  }
  
  void onCameraRestarted() {
    _shouldRestartCamera = false;
  }
  
  void hideFallbackAndRestart() {
    _timeoutTimer?.cancel();
    _showFallback = false;
    _isScanning = true;
    _scannedBook = null;
    _error = null;
    
    // Signal that camera needs to be restarted (iOS fix)
    _shouldRestartCamera = true;
    notifyListeners();
    
    // Restart timeout
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (_scannedBook == null && _isScanning) {
        _showFallbackUI();
      }
    });
  }
  
  void cleanup() {
    // Only clean up timers and temporary state, but preserve parameters
    _timeoutTimer?.cancel();
    _isScanning = false;
    _showFallback = false;
    _scannedBook = null;
    _error = null;
    _shouldRestartCamera = false;
    // Don't reset _addingBook and _bookboxId as they might be needed for next visit
    notifyListeners();
  }
  
  void fullReset() {
    // Complete reset including parameters - only use when truly disposing the ViewModel
    _timeoutTimer?.cancel();
    _isScanning = false;
    _showFallback = false;
    _scannedBook = null;
    _error = null;
    _shouldRestartCamera = false;
    _addingBook = null;
    _bookboxId = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }
}

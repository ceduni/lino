import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/services/book_services.dart';

class BarcodeScannerViewModel extends ChangeNotifier {
  final BookService _bookService = BookService();
  
  // State variables
  bool _isScanning = true;
  bool _showFallback = false;
  EditableBook? _scannedBook;
  String? _error;
  Timer? _timeoutTimer;
  
  // Getters
  bool get isScanning => _isScanning;
  bool get showFallback => _showFallback;
  EditableBook? get scannedBook => _scannedBook;
  String? get error => _error;
  
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
    
    // Cancel timeout since we got a barcode
    _timeoutTimer?.cancel();
    
    try {
      // Validate that it's a potential ISBN (10 or 13 digits)
      final cleanBarcode = barcode.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanBarcode.length != 10 && cleanBarcode.length != 13) {
        // Invalid ISBN format, continue scanning
        return;
      }
      
      _error = null;
      notifyListeners();
      
      // Fetch book info
      final book = await _bookService.getBookInfo(barcode);
      _scannedBook = book;
      _isScanning = false;
      notifyListeners();
      
    } catch (e) {
      // If book not found, continue scanning (don't show error immediately)
      _error = null;
      // Don't stop scanning, let the timeout handle showing fallback
    }
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
    notifyListeners();
    
    // Restart timeout
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (_scannedBook == null && _isScanning) {
        _showFallbackUI();
      }
    });
  }
  
  void hideFallbackAndRestart() {
    _timeoutTimer?.cancel();
    _showFallback = false;
    _isScanning = true;
    _scannedBook = null;
    _error = null;
    notifyListeners();
    
    // Restart timeout
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (_scannedBook == null && _isScanning) {
        _showFallbackUI();
      }
    });
  }
  
  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }
}

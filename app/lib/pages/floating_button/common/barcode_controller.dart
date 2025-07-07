import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeController extends GetxController with WidgetsBindingObserver {
  final MobileScannerController scannerController = MobileScannerController();
  StreamSubscription<Object?>? _subscription;
  var barcodeObs = ''.obs;
  // var isScanned = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _subscription = scannerController.barcodes.listen(_handleBarcode);
    await scannerController.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!scannerController.value.isInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _subscription = scannerController.barcodes.listen(_handleBarcode);
        scannerController.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        // Handle hidden state if needed
        break;
    }
  }

  @override
  Future<void> onClose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _stopScanner();
    scannerController.dispose();
    super.onClose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      final barcode = capture.barcodes.first.rawValue;
      barcodeObs.value = barcode ?? 'Unknown Barcode';
      // isScanned.value = barcode != null;
      // if (barcode != null) _stopScanner();
    } else {
      barcodeObs.value = 'No Barcode Detected';
    }
  }

  Future<void> _stopScanner() async {
    await scannerController.stop();
    await _subscription?.cancel();
    _subscription = null;
  }

  void resetScanState() {
    barcodeObs.value = '';
    // isScanned.value = false;
    scannerController.start();
    _subscription = scannerController.barcodes.listen(_handleBarcode);
  }
}

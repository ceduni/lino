import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeController extends GetxController with WidgetsBindingObserver {
  final MobileScannerController scannerController = MobileScannerController();
  StreamSubscription<Object?>? _subscription;
  var barcodeObs = ''.obs;
  var isScanned = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _subscription = scannerController.barcodes.listen(_handleBarcode);
    unawaited(scannerController.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!scannerController.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        _subscription = scannerController.barcodes.listen(_handleBarcode);
        unawaited(scannerController.start());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(scannerController.stop());
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  Future<void> onClose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    await scannerController.dispose();
    super.onClose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      final barcode = capture.barcodes.first;
      if (barcode.rawValue != null) {
        barcodeObs.value = barcode.rawValue!;
        isScanned.value = true;
        stopScanner();
      } else {
        barcodeObs.value = 'Unknown Barcode';
      }
    } else {
      barcodeObs.value = 'No Barcode Detected';
    }
  }

  void stopScanner() {
    unawaited(scannerController.stop());
    _subscription?.cancel();
  }

  void resetScanState() {
    barcodeObs.value = '';
    isScanned.value = false;
    unawaited(scannerController.start());
    _subscription = scannerController.barcodes.listen(_handleBarcode);
  }
}

typedef BarcodeSubmitCallback = void Function(String qrCode);

class BarcodeScanner extends StatelessWidget {
  final BarcodeController barcodeController = Get.put(BarcodeController());
  final BarcodeSubmitCallback? submitAction;

  BarcodeScanner({super.key, this.submitAction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barcode Scanner')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: barcodeController.scannerController,
              fit: BoxFit.contain,
            ),
          ),
          Obx(() {
            if (barcodeController.isScanned.value) {
              return _buildConfirmation(context);
            } else {
              return Container();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildConfirmation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Barcode: ${barcodeController.barcodeObs.value}',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          Text('Is this scan correct?'),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Submit the scanned barcode
                  _submitBarcode(context);
                },
                child: Text('Yes'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Reset the scan state to scan again
                  barcodeController.resetScanState();
                },
                child: Text('No'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitBarcode(BuildContext context) {
    if (submitAction != null) {
      submitAction!(
          barcodeController.barcodeObs.value); // Temp hard coded bbox id valu);
    }

    showToast('Barcode submitted: ${barcodeController.barcodeObs.value}');

    Navigator.of(context).pop(); // Close the dialog after submission
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

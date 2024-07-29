import 'dart:async';

import 'package:Lino_app/nav_menu.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:Lino_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }
}

class AddBookScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  static final List<Widget> pages = <Widget>[
    HaveISBNWidget(),
    HaveNotISBNWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Book Screen'),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Text(
            'Avez-vous ISBN du livre ?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => controller.changePage(0),
                child: Text('Oui, j\'ai l\'ISBN'),
              ),
              ElevatedButton(
                onPressed: () => controller.changePage(1),
                child: Text('Non je n\'ai pas l\'ISBN'),
              ),
            ],
          ),
          Expanded(
            child: Obx(() => pages.elementAt(controller.selectedIndex.value)),
          ),
        ],
      ),
    );
  }
}

class HaveISBNWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarcodeScanner(submitAction: (qrCode) {
      // Add book to the database
      final bookService = BookService();
      bookService.addBookToBB(qrCode, '669d52d67ea5a6dc624fc4b6');
    });
  }
}

class HaveNotISBNWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: LinoSizes.spaceBtwSections),
          buildTextField('Titre du livre'),
          SizedBox(height: LinoSizes.spaceBtwSections),
          buildTextField('Auteur du livre'),
          SizedBox(height: LinoSizes.spaceBtwSections),
          buildTextField('Description du livre'),
          SizedBox(height: LinoSizes.spaceBtwSections),
          TextButton(
            onPressed: () {
              // Add book to the database
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    body: BarcodeScanner(),
                    appBar: AppBar(title: Text('Scan QR Code')),
                  ),
                ),
              );
            },
            child: Text('Ajouter le livre'),
          )
        ],
      ),
    );
  }

  TextField buildTextField(String label) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
      ),
    );
  }
}

class RemoveBookScreen extends StatelessWidget {
  const RemoveBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remove Book Screen'),
      ),
      body: BarcodeScanner(),
    );
  }
}

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Barcode submitted: ${barcodeController.barcodeObs.value}'),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookNavPage()),
    );
  }
}

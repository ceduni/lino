import 'dart:async';

import 'package:Lino_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
          Column(
            children: [
              SizedBox(height: 16), // Adds spacing between AppBar and title
              Text(
                'Avez-vous ISBN du livre ?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      controller.changePage(0);
                    },
                    child: Text('Oui, j\'ai ISBN'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.changePage(1);
                    },
                    child: Text('Non j\'ai pas ISBN'),
                  ),
                ],
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
    return BarcodeScanner();
  }
}

class HaveNotISBNWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        SizedBox(height: LinoSizes.spaceBtwSections),
        Text('Titre du livre'),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Quit yapping and enter the title',
          ),
        ),
        SizedBox(height: LinoSizes.spaceBtwSections),
        Text('Auteur du livre'),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Quit yapping and enter the author',
          ),
        ),
        SizedBox(height: LinoSizes.spaceBtwSections),
        Text('Description du livre'),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Quit yapping and enter the description',
          ),
        ),
        SizedBox(height: LinoSizes.spaceBtwSections),
        TextButton(
          onPressed: () {
            // Add book to the database
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Scaffold(
                      body: BarcodeScanner(),
                      appBar: AppBar(title: Text('Scan QR Code')))),
            );
          },
          child: Text('Ajouter le livre'),
        )
      ]),
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

class BarcodeScanner extends StatelessWidget {
  final BarcodeController barcodeController = Get.put(BarcodeController());
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MobileScanner(
            controller: barcodeController.scannerController,
            fit: BoxFit.contain,
          ),
        ),
        Obx(() => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Barcode: ${barcodeController.barcodeObs.value}',
                style: TextStyle(fontSize: 18),
              ),
            )),
      ],
    );
  }
}

class BarcodeController extends GetxController with WidgetsBindingObserver {
  final MobileScannerController scannerController = MobileScannerController();
  StreamSubscription<Object?>? _subscription;
  var barcodeObs = ''.obs;

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
      } else {
        barcodeObs.value = 'Unknown Barcode';
      }
    } else {
      barcodeObs.value = 'No Barcode Detected';
    }
  }
}

class QRController extends GetxController {
  var qrText = ''.obs;
  QRViewController? qrViewController;

  void setQrText(String text) {
    qrText.value = text;
  }

  void onQRViewCreated(QRViewController controller) {
    qrViewController = controller;
    controller.scannedDataStream.listen((scanData) {
      setQrText(scanData.code!);
    });
  }

  @override
  void onClose() {
    qrViewController?.dispose();
    super.onClose();
  }
}

class QRViewExample extends StatelessWidget {
  final QRController qrController = Get.put(QRController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: QRView(
            key: GlobalKey(debugLabel: 'QR'),
            onQRViewCreated: qrController.onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Obx(() => Text('Scan result: ${qrController.qrText}')),
          ),
        ),
      ],
    );
  }
}

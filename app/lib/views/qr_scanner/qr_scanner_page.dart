import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:vibration/vibration.dart';
import 'package:Lino_app/l10n/app_localizations.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;

  @override
  void initState() {
    super.initState();
    _screenOpened = false;
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.scanQRCode,
          style: TextStyle(
            fontFamily: 'Kanit',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(66, 119, 184, 1),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: cameraController,
                    onDetect: _foundBarcode,
                  ),
                  // Overlay with scanning frame
                  Container(
                    decoration: ShapeDecoration(
                      shape: QrScannerOverlayShape(
                        borderColor: const Color.fromRGBO(239, 174, 133, 1),
                        borderRadius: 10,
                        borderLength: 30,
                        borderWidth: 10,
                        cutOutSize: 250,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.pointCameraAtQRCode,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      AppLocalizations.of(context)!.qrCodeScannedAutomatically,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Kanit',
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () => cameraController.toggleTorch(),
                          icon: const Icon(Icons.flash_on, color: Colors.grey),
                          tooltip: AppLocalizations.of(context)!.toggleFlash,
                        ),
                        IconButton(
                          onPressed: () => cameraController.switchCamera(),
                          icon: const Icon(Icons.camera_rear, color: Colors.grey),
                          tooltip: AppLocalizations.of(context)!.switchCamera,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _foundBarcode(BarcodeCapture capture) {
    if (!_screenOpened) {
      final List<Barcode> barcodes = capture.barcodes;
      for (final barcode in barcodes) {
        if (barcode.rawValue != null) {
          _screenOpened = true;
          _handleScannedCode(barcode.rawValue!);
          break;
        }
      }
    }
  }

  void _handleScannedCode(String code) async{
    // Check if the scanned code is a URL that matches the expected pattern
    final RegExp urlPattern = RegExp(
      r'https://ceduni-lino\.netlify\.app/bookbox/([a-fA-F0-9]{24})',
      caseSensitive: false,
    );
    
    final match = urlPattern.firstMatch(code);
    
    if (match != null) {
      // Extract the bookbox ID from the URL
      final String bookboxId = match.group(1)!;

      try {
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 250);
        }
      } catch (e) {
      }
      
      // Navigate to the bookbox page with the extracted ID
      Get.back(); // Close the scanner page first
      Get.toNamed(
        AppRoutes.bookbox.main,
        arguments: {
          'bookboxId': bookboxId,
          'canInteract': true,
        },
      );
    } else {
      // Show error dialog for invalid QR code
      _showInvalidQRDialog(code);
    }
  }

  void _showInvalidQRDialog(String scannedCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.invalidQRCodeTitle,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.notValidLinoBookboxCode,
                style: TextStyle(fontFamily: 'Kanit'),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.scannedContent,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  scannedCode,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                setState(() {
                  _screenOpened = false; // Allow scanning again
                });
              },
              child: Text(
                AppLocalizations.of(context)!.tryAgainButton,
                style: TextStyle(fontFamily: 'Kanit'),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.back(); // Close scanner page
              },
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(fontFamily: 'Kanit'),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom overlay shape for the QR scanner
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    double? cutOutSize,
  }) : cutOutSize = cutOutSize ?? 250;

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _cutOutSize = cutOutSize < width && cutOutSize < height
        ? cutOutSize
        : (width < height ? width : height) - borderWidthSize;
    final _cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - _cutOutSize / 2 + borderOffset,
      _cutOutSize - borderOffset * 2,
      _cutOutSize - borderOffset * 2,
    );

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(_cutOutRect, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final borderPath = Path();

    // Top-left corner
    borderPath.moveTo(_cutOutRect.left - borderOffset, _cutOutRect.top + borderLength);
    borderPath.lineTo(_cutOutRect.left - borderOffset, _cutOutRect.top + borderRadius);
    borderPath.quadraticBezierTo(_cutOutRect.left - borderOffset, _cutOutRect.top - borderOffset,
        _cutOutRect.left + borderRadius, _cutOutRect.top - borderOffset);
    borderPath.lineTo(_cutOutRect.left + borderLength, _cutOutRect.top - borderOffset);

    // Top-right corner
    borderPath.moveTo(_cutOutRect.right - borderLength, _cutOutRect.top - borderOffset);
    borderPath.lineTo(_cutOutRect.right - borderRadius, _cutOutRect.top - borderOffset);
    borderPath.quadraticBezierTo(_cutOutRect.right + borderOffset, _cutOutRect.top - borderOffset,
        _cutOutRect.right + borderOffset, _cutOutRect.top + borderRadius);
    borderPath.lineTo(_cutOutRect.right + borderOffset, _cutOutRect.top + borderLength);

    // Bottom-right corner
    borderPath.moveTo(_cutOutRect.right + borderOffset, _cutOutRect.bottom - borderLength);
    borderPath.lineTo(_cutOutRect.right + borderOffset, _cutOutRect.bottom - borderRadius);
    borderPath.quadraticBezierTo(_cutOutRect.right + borderOffset, _cutOutRect.bottom + borderOffset,
        _cutOutRect.right - borderRadius, _cutOutRect.bottom + borderOffset);
    borderPath.lineTo(_cutOutRect.right - borderLength, _cutOutRect.bottom + borderOffset);

    // Bottom-left corner
    borderPath.moveTo(_cutOutRect.left + borderLength, _cutOutRect.bottom + borderOffset);
    borderPath.lineTo(_cutOutRect.left + borderRadius, _cutOutRect.bottom + borderOffset);
    borderPath.quadraticBezierTo(_cutOutRect.left - borderOffset, _cutOutRect.bottom + borderOffset,
        _cutOutRect.left - borderOffset, _cutOutRect.bottom - borderRadius);
    borderPath.lineTo(_cutOutRect.left - borderOffset, _cutOutRect.bottom - borderLength);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}

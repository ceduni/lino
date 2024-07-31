import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCConnectDialog {
  String keyIsFirstLoaded = 'isFirstLoaded';
  String keyNFCId = 'nfcId';

  void openFirstLoadedPrompt(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLoaded = prefs.getBool(keyIsFirstLoaded);
    if (isFirstLoaded == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text('Welcome!'),
            content: Text('Are you near a bookbox?'),
            actions: [
              TextButton(
                onPressed: () {
                  // Open NFC prompt
                  openNFCPrompt(context);
                },
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('No'),
              ),
            ],
          );
        },
      );
      // prefs.setBool(keyIsFirstLoaded, false);
    }
  }

  Future<void> openNFCPrompt(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      //We first check if NFC is available on the device.
      if (isAvailable) {
        //If NFC is available, start an NFC session and listen for NFC tags to be discovered.
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            // Process NFC tag, When an NFC tag is discovered, print its data to the console.
            debugPrint('NFC Tag Detected: ${tag.data}');
            // Save the NFC tag data to shared preferences
            // prefs.setString(keyNFCId, tag.data);
          },
        );
      } else {
        debugPrint('NFC not available.');
      }
    } catch (e) {
      debugPrint('Error reading NFC: $e');
    }
  }
}

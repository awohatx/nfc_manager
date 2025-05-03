import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCDiscoveryWidget extends StatelessWidget {
  final Function(String) onTagDiscovered;
  final String buttonText;
  final ButtonStyle? buttonStyle;

  NFCDiscoveryWidget({
    required this.onTagDiscovered,
    this.buttonText = 'Start NFC Discovery',
    this.buttonStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: buttonStyle,
      onPressed: () async {
        try {
          bool isAvailable = await NfcManager.instance.isAvailable();
          if (isAvailable) {
            NfcManager.instance.startSession(onDiscovered: (NfcTag tag) {
              onTagDiscovered(tag.data.toString());
              NfcManager.instance.stopSession();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('NFC is not available on this device')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error starting NFC session: $e')),
          );
        }
      },
      child: Text(buttonText),
    );
  }
}
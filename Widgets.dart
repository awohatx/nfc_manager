import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCDiscoveryWidget extends StatelessWidget {
  final Function(String) onTagDiscovered;

  NFCDiscoveryWidget({required this.onTagDiscovered});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
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
      },
      child: Text('Start NFC Discovery'),
    );
  }
}
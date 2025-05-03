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

class TagReader {

    fun readNDEF(tag: Tag): String? {
        val ndef = Ndef.get(tag)
        return try {
            ndef?.connect()
            ndef?.cachedNdefMessage?.toString()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        } finally {
            ndef?.close()
        }
    }

    fun writeNDEF(tag: Tag, message: String): Boolean {
        val ndef = Ndef.get(tag)
        return try {
            ndef?.connect()
            val ndefMessage = NdefMessage(NdefRecord.createTextRecord("en", message))
            ndef?.writeNdefMessage(ndefMessage)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        } finally {
            ndef?.close()
        }
    }

    fun findRootPIN(tag: Tag): String? {
        val isoDep = IsoDep.get(tag)
        return try {
            isoDep.connect()

            // Example APDU command to retrieve the root PIN
            val getPinCommand = byteArrayOf(
                0x00.toByte(), 0xCA.toByte(), 0x00.toByte(), 0x00.toByte(), 0x00.toByte()
            )

            val pinResponse = isoDep.transceive(getPinCommand)

            // Convert the response to a readable string (assuming the PIN is in ASCII format)
            String(pinResponse, Charsets.UTF_8)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        } finally {
            isoDep.close()
        }
    }
}
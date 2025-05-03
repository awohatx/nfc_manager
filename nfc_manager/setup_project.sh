#!/bin/bash

# Define the root directory for the project
ROOT_DIR="nfc_manager"

# Create the main project structure
echo "Creating main project structure..."
mkdir -p $ROOT_DIR/{lib,example,android/src/{main/{kotlin/dev/huynh/nfc_manager_android/{host_card_emulation,reader},res/xml},test/kotlin/dev/huynh/nfc_manager_android/reader}}

# Create the platform interface directory
PLATFORM_INTERFACE_DIR="${ROOT_DIR}_platform_interface"
mkdir -p $PLATFORM_INTERFACE_DIR/lib

# Create the Android-specific implementation directory
ANDROID_DIR="${ROOT_DIR}_android"
mkdir -p $ANDROID_DIR/android/src/{main/{kotlin/dev/huynh/nfc_manager_android/{host_card_emulation,reader},res/xml},test/kotlin/dev/huynh/nfc_manager_android/reader}

# Create necessary files
echo "Creating necessary files..."

# Create the apduservice.xml file
cat <<EOL > $ANDROID_DIR/android/src/main/res/xml/apduservice.xml
<host-apdu-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:description="@string/service_description"
    android:requireDeviceUnlock="false">
    <aid-group android:category="payment" android:description="@string/aid_group_description">
        <aid-filter android:name="A0000002471001" />
        <aid-filter android:name="A0000002472001" />
    </aid-group>
</host-apdu-service>
EOL

# Create the AndroidManifest.xml file
cat <<EOL > $ANDROID_DIR/android/src/main/AndroidManifest.xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="dev.huynh.nfc_manager_android">
    <uses-permission android:name="android.permission.NFC" />
    <application>
        <service
            android:name=".host_card_emulation.HostCardEmulation"
            android:permission="android.permission.BIND_NFC_SERVICE">
            <intent-filter>
                <action android:name="android.nfc.cardemulation.action.HOST_APDU_SERVICE" />
            </intent-filter>
            <meta-data
                android:name="android.nfc.cardemulation.host_apdu_service"
                android:resource="@xml/apduservice" />
        </service>
    </application>
</manifest>
EOL

# Create the strings.xml file
cat <<EOL > $ANDROID_DIR/android/src/main/res/values/strings.xml
<resources>
    <string name="service_description">NFC Host Card Emulation Service</string>
    <string name="aid_group_description">Supported AIDs</string>
</resources>
EOL

# Create a placeholder Dart file for the Flutter plugin
cat <<EOL > $ROOT_DIR/lib/nfc_manager.dart
library nfc_manager;

// Export platform interface
export 'package:nfc_manager_platform_interface/nfc_manager_platform_interface.dart';
EOL

# Create a placeholder widget file
cat <<EOL > $ROOT_DIR/lib/widgets/nfc_discovery_widget.dart
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
            SnackBar(content: Text('Error starting NFC session: \$e')),
          );
        }
      },
      child: Text(buttonText),
    );
  }
}
EOL

# Create a placeholder test file
cat <<EOL > $ANDROID_DIR/android/src/test/kotlin/dev/huynh/nfc_manager_android/reader/TagReaderTest.kt
package dev.huynh.nfc_manager_android.reader

import android.nfc.Tag
import org.junit.Test
import org.junit.Assert.*
import org.mockito.Mockito.*

class TagReaderTest {
    private lateinit var tagReader: TagReader

    @Before
    fun setUp() {
        tagReader = TagReader()
    }

    @Test
    fun testReadNDEF() {
        val mockTag = mock(Tag::class.java)
        val result = tagReader.readNDEF(mockTag)
        assertNull(result) // Assuming no NDEF data is present
    }

    @Test
    fun testWriteNDEF() {
        val mockTag = mock(Tag::class.java)
        val result = tagReader.writeNDEF(mockTag, "Hello NFC")
        assertFalse(result) // Assuming the tag is not writable
    }
}
EOL

# Final message
echo "Project structure and files created successfully!"
# Contributor Covenant Code of Conduct

## Our Pledge

We as members, contributors, and leaders pledge to make participation in our
community a harassment-free experience for everyone, regardless of age, body
size, visible or invisible disability, ethnicity, sex characteristics, gender
identity and expression, level of experience, education, socio-economic status,
nationality, personal appearance, race, caste, color, religion, or sexual
identity and orientation.

We pledge to act and interact in ways that contribute to an open, welcoming,
diverse, inclusive, and healthy community.

## Our Standards

Examples of behavior that contributes to a positive environment for our
community include:


* Demonstrating empathy and kindness toward other people
* Being respectful of differing opinions, viewpoints, and experiences
* Giving and gracefully accepting constructive feedback
* Accepting responsibility and apologizing to those affected by our mistakes,
  and learning from the experience
* Focusing on what is best not just for us as individuals, but for the overall
  community

Examples of unacceptable behavior include:

* The use of sexualized language or imagery, and sexual attention or advances of
  any kind
* Trolling, insulting or derogatory comments, and personal or political attacks
* Public or private harassment
* Publishing others' private information, such as a physical or email address,
  without their explicit permission
* Other conduct which could reasonably be considered inappropriate in a
  professional setting

## Enforcement Responsibilities

Community leaders are responsible for clarifying and enforcing our standards of
acceptable behavior and will take appropriate and fair corrective action in
response to any behavior that they deem inappropriate, threatening, offensive,
or harmful.

Community leaders have the right and responsibility to remove, edit, or reject
comments, commits, code, wiki edits, issues, and other contributions that are
not aligned to this Code of Conduct, and will communicate reasons for moderation
decisions when appropriate.

## Scope

This Code of Conduct applies within all community spaces, and also applies when
an individual is officially representing the community in public spaces.
Examples of representing our community include using an official email address,
posting via an official social media account, or acting as an appointed
representative at an online or offline event.

## Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be
reported to the community leaders responsible for enforcement at
ngoc.quoci.huynh@gmail.com.
All complaints will be reviewed and investigated promptly and fairly.

All community leaders are obligated to respect the privacy and security of the
reporter of any incident.

## Enforcement Guidelines

Community leaders will follow these Community Impact Guidelines in determining
the consequences for any action they deem in violation of this Code of Conduct:

### 1. Correction

**Community Impact**: Use of inappropriate language or other behavior deemed
unprofessional or unwelcome in the community.

**Consequence**: A private, written warning from community leaders, providing
clarity around the nature of the violation and an explanation of why the
behavior was inappropriate. A public apology may be requested.

### 2. Warning

**Community Impact**: A violation through a single incident or series of
actions.

**Consequence**: A warning with consequences for continued behavior. No
interaction with the people involved, including unsolicited interaction with
those enforcing the Code of Conduct, for a specified period of time. This
includes avoiding interactions in community spaces as well as external channels
like social media. Violating these terms may lead to a temporary or permanent
ban.

### 3. Temporary Ban

**Community Impact**: A serious violation of community standards, including
sustained inappropriate behavior.

**Consequence**: A temporary ban from any sort of interaction or public
communication with the community for a specified period of time. No public or
private interaction with the people involved, including unsolicited interaction
with those enforcing the Code of Conduct, is allowed during this period.
Violating these terms may lead to a permanent ban.

### 4. Permanent Ban

**Community Impact**: Demonstrating a pattern of violation of community
standards, including sustained inappropriate behavior, harassment of an
individual, or aggression toward or disparagement of classes of individuals.

**Consequence**: A permanent ban from any sort of public interaction within the
community.

## Attribution

This Code of Conduct is adapted from the [Contributor Covenant][homepage],
version 2.1, available at
[https://www.contributor-covenant.org/version/2/1/code_of_conduct.html][v2.1].

Community Impact Guidelines were inspired by
[Mozilla's code of conduct enforcement ladder][Mozilla CoC].

For answers to common questions about this code of conduct, see the FAQ at
[https://www.contributor-covenant.org/faq][FAQ]. Translations are available at
[https://www.contributor-covenant.org/translations][translations].

[homepage]: https://www.contributor-covenant.org
[v2.1]: https://www.contributor-covenant.org/version/2/1/code_of_conduct.html
[Mozilla CoC]: https://github.com/mozilla/diversity
[FAQ]: https://www.contributor-covenant.org/faq
[translations]: https://www.contributor-covenant.org/translations

---

```kotlin
class HostCardEmulation : HostApduService() {
    private val registeredAIDs = mutableMapOf<String, String>() // AID -> PIN

    fun registerAID(aid: String, pin: String) {
        registeredAIDs[aid] = pin
    }

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray? {
        val aid = extractAID(commandApdu)
        val pin = extractPIN(commandApdu)

        if (aid != null && registeredAIDs.containsKey(aid)) {
            return if (registeredAIDs[aid] == pin) {
                "9000".toByteArray() // Success
            } else {
                "6982".toByteArray() // Security condition not satisfied
            }
        }
        return "6A82".toByteArray() // File not found
    }

    private fun extractAID(commandApdu: ByteArray?): String? {
        // Logic to extract AID from APDU
        return "A0000002471001" // Example AID
    }

    private fun extractPIN(commandApdu: ByteArray?): String? {
        // Logic to extract PIN from APDU
        return "1234" // Example PIN
    }
}

class TagReader {
    fun readNDEF(tag: Tag): String? {
        val ndef = Ndef.get(tag)
        return ndef?.cachedNdefMessage?.toString()
    }

    fun writeNDEF(tag: Tag, message: String): Boolean {
        val ndef = Ndef.get(tag)
        return try {
            ndef.connect()
            val ndefMessage = NdefMessage(NdefRecord.createTextRecord("en", message))
            ndef.writeNdefMessage(ndefMessage)
            true
        } catch (e: Exception) {
            false
        } finally {
            ndef.close()
        }
    }
}

sealed class NFCException(message: String) : Exception(message)

class TagNotSupportedException : NFCException("The NFC tag is not supported.")
class NDEFWriteException : NFCException("Failed to write NDEF message to the tag.")
class HCERegistrationException : NFCException("Failed to register AID for Host Card Emulation.")

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

@RunWith(AndroidJUnit4::class)
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
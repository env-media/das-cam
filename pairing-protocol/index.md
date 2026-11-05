---
title: How Das Cam pairs two devices
---

# How Das Cam pairs two devices and protects their connection

**Not legal advice: a technical description.** It describes the protocol Das Cam (version 1) uses between two paired
devices, and is published so anyone can read and check the design. Das Cam runs on iPhone and iPad today,
and "device" here means either. It uses only standard algorithms from Apple's
CryptoKit. Nothing here is secret: the security rests on keys that never leave the two devices.

## The first pairing

1. The user of one device taps **Pair**, and the other device's user allows it. The devices connect over Apple's
   Multipeer Connectivity.
2. Each device makes a fresh **X25519** key pair and a 16-byte random nonce, and sends its public key. The device with
   the larger public key reveals first ("A"); the other commits first ("B").
3. **B commits** before it sees A's nonce: HMAC-SHA256, keyed with B's nonce, over a label and both public keys.
4. **A reveals** its nonce. Then **B reveals** its nonce, and A checks B's commitment.
5. Both devices compute a **6-digit code**:
   - SHA-256 over a label, both public keys and both nonces;
   - the first four bytes, as a number, modulo 1,000,000.

   Each user checks that both devices show the same code, and confirms on their own device.
6. Both derive the **pair secret**:
   - the X25519 shared secret goes through **HKDF-SHA256** (salt: both nonces; info: a label and a SHA-256 hash of the
     whole exchange), giving 32 bytes;
   - the pair's identifier is a hash of the same exchange;
   - each device then confirms with HMAC-SHA256 of the secret over a label and its role;
   - a device accepts the pairing only when its own user confirmed AND the other device's confirmation checks out.

Each side's nonce is fixed before the other's is known, so a device in the middle gets **one guess** at the code: a
one-in-a-million chance, and a failed guess shows two different codes. Each device keeps the secret in its Keychain,
for this device only: it is never synchronized or backed up.

## Every later connection: a mutual proof

Before either device accepts a command or a video frame, both prove they hold the pair secret.
- Each sends a fresh 16-byte nonce.
- Each then sends HMAC-SHA256 of the secret over a label, its role, the pair's identifier and both nonces.
- Each proof is checked in constant time.
- The role in the MAC defeats a reflected proof.
- Until both proofs check out, nothing else is processed.
- An older version that cannot prove is never paired silently: its user is asked to update.

## Protecting every message

- **Keys:** for each connection, each direction and each stream (commands, video preview), a separate 256-bit key from
  HKDF-SHA256 of the pair secret (salt: both connection nonces; info: a label, the direction and the stream). Every
  connection gets new keys.
- **Cipher:** **AES-256-GCM**:
  - the 12-byte nonce is a 4-byte stream-and-direction tag and an 8-byte counter, which never repeats under a key;
  - the tag is 16 bytes;
  - the associated data names the stream and the direction.
- **Commands** (TCP or Multipeer): each message's counter must be exactly one more than the last. A gap, a repeat or a
  failed tag ends the connection.
- **Video preview** (UDP): a 1,024-wide replay window accepts packets that arrive out of order. It drops duplicates,
  packets too old for the window, and anything whose tag fails.

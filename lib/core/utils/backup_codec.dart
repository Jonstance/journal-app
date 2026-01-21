import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class BackupEnvelope {
  BackupEnvelope({
    required this.salt,
    required this.nonce,
    required this.cipherText,
    required this.mac,
  });

  final Uint8List salt;
  final Uint8List nonce;
  final Uint8List cipherText;
  final Uint8List mac;

  Map<String, dynamic> toJson() {
    return {
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'cipherText': base64Encode(cipherText),
      'mac': base64Encode(mac),
    };
  }

  static BackupEnvelope fromJson(Map<String, dynamic> json) {
    return BackupEnvelope(
      salt: base64Decode(json['salt'] as String),
      nonce: base64Decode(json['nonce'] as String),
      cipherText: base64Decode(json['cipherText'] as String),
      mac: base64Decode(json['mac'] as String),
    );
  }
}

class BackupCodec {
  BackupCodec({
    required this.kdf,
    required this.cipher,
  });

  final Pbkdf2 kdf;
  final AesGcm cipher;

  static BackupCodec standard() {
    return BackupCodec(
      kdf: Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: 120000,
        bits: 256,
      ),
      cipher: AesGcm.with256bits(),
    );
  }

  Future<BackupEnvelope> encrypt(String passphrase, Uint8List plain) async {
    final salt = _randomBytes(16);
    final secretKey = await kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
    final nonce = _randomBytes(12);
    final secretBox = await cipher.encrypt(
      plain,
      secretKey: secretKey,
      nonce: nonce,
    );

    return BackupEnvelope(
      salt: salt,
      nonce: Uint8List.fromList(secretBox.nonce),
      cipherText: Uint8List.fromList(secretBox.cipherText),
      mac: Uint8List.fromList(secretBox.mac.bytes),
    );
  }

  Future<Uint8List> decrypt(String passphrase, BackupEnvelope envelope) async {
    final secretKey = await kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: envelope.salt,
    );
    final secretBox = SecretBox(
      envelope.cipherText,
      nonce: envelope.nonce,
      mac: Mac(envelope.mac),
    );

    final clear = await cipher.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return Uint8List.fromList(clear);
  }

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => random.nextInt(256)));
  }
}

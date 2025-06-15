import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class EncryptionUtil {
  final Encrypter _encrypter;
  final IV _iv = IV.fromLength(16);

  EncryptionUtil(String key)
      : _encrypter = Encrypter(
          AES(Key.fromUtf8(key.padRight(32).substring(0, 32))),
        );

  String encrypt(Uint8List data) {
    final encrypted = _encrypter.encryptBytes(data, iv: _iv);
    return encrypted.base64;
  }

  Uint8List decrypt(String base64) {
    return Uint8List.fromList(
        _encrypter.decryptBytes(Encrypted.fromBase64(base64), iv: _iv));
  }
}
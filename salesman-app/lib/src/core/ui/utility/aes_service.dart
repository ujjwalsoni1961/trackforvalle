// import 'dart:convert';

// import 'package:encrypt/encrypt.dart';

// class AESService {
//   String key = "5q4Wxm6imm+SY1uaPOQcqVufFx0fiYMePGUExJQs3rI=";
//   String iv = "FF0Ktzn0E7aRdsJ2XOQNvw==";
//   String decryptAES(
//       String encryptedMessage, String keyBase64, String ivBase64) {
//     // Convert the base64 key and IV to Uint8List
//     final keyBytes = base64Decode(keyBase64);
//     final ivBytes = base64Decode(ivBase64);

//     // Create the Encrypter, using AES with the specified key and IV
//     final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.cbc));

//     // Create an IV object from the IV bytes
//     final iv = IV(ivBytes);

//     // Decrypt the message. The encrypted message is expected to be in hex format.
//     final decrypted = encrypter.decrypt16(encryptedMessage, iv: iv);

//     return decrypted;
//   }

//   String encryptAES(String message, String keyBase64, String ivBase64) {
//     // Convert the base64 key and IV to Uint8List
//     final keyBytes = base64Decode(keyBase64);
//     final ivBytes = base64Decode(ivBase64);

//     // Create the Encrypter, using AES with the specified key and IV
//     final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.cbc));

//     // Create an IV object from the IV bytes
//     final iv = IV(ivBytes);

//     // Encrypt the message
//     final encrypted = encrypter.encrypt(message, iv: iv);

//     return encrypted.base64;
//   }
// }

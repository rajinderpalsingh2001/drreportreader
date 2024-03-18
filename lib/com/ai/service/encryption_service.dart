// import 'package:lzstring/lzstring.dart';
import 'dart:convert';
import 'package:archive/archive.dart';

class EncryptionService {
  static String compress(String json) {
    List<int> stringBytes = utf8.encode(json);
    List<int> zlibBytes = ZLibEncoder().encode(stringBytes);
    var compressedString = base64.encode(zlibBytes);
    return compressedString;
  }

  static String decompress(String compressedString) {
    List<int> decodedBase64 = base64.decode(compressedString);
    List<int> zlibBytes = ZLibDecoder().decodeBytes(decodedBase64);
    String decompressedString = utf8.decode(zlibBytes);
    return decompressedString;
  }
}

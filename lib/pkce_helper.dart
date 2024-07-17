import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PkceHelper {
  static const String _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  static final Random _rnd = Random();
  static const clientId = "9c8940e0-1c72-4272-9b1e-257523170731";
  // Generate a secure random string - Code Verifier
  static String generateCodeVerifier() =>
      String.fromCharCodes(Iterable.generate(
        128,
        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
      ));

  // Generate the Code Challenge from Code Verifier
  static String generateCodeChallenge(String verifier) {
    var bytes = utf8.encode(verifier);
    var digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const String clientId = '9c8b61ce-5d51-4b7a-b73a-7c827da91f7a';
const String appUrl = 'http://192.168.0.132:8000';
const String authenticate = '/oauth/authorize';
const String tokenRoute = '/oauth/token';

class OAuthService {
  static const String redirectUri = 'com.oauthtest://callback';
  static String authorisationEndpoint = '$appUrl$authenticate';
  static String tokenEndpoint = '$appUrl$tokenRoute';
  late final String codeVerifier; // TODO: store in flutter secure storage.

  String generateCodeVerifier() {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    final length =
        43 + random.nextInt(86); // Length between 43 and 128 characters
    final verifier =
        List.generate(length, (_) => charset[random.nextInt(charset.length)])
            .join();
    return verifier;
  }

  String _generateCodeChallenge(String codeVerifier) {
    List<int> codeVerifierBytes = utf8.encode(codeVerifier);
    // Hash the codeVerifier using SHA-256
    List<int> hash = sha256.convert(codeVerifierBytes).bytes;
    // Base64-url-encode the hash and remove padding
    String codeChallenge = base64Url.encode(hash).replaceAll('=', '');
    return codeChallenge;
  }

  Future<void> initiateAuthProcess() async {
    codeVerifier = generateCodeVerifier();
    final String codeChallenge = _generateCodeChallenge(codeVerifier);
    const String codeChallengeMethod = 'S256';

    String authorisationUrl =
        '$authorisationEndpoint?response_type=code&client_id=$clientId&redirect_uri=$redirectUri&code_challenge=$codeChallenge&code_challenge_method=$codeChallengeMethod';

    if (await canLaunchUrl(Uri.parse(authorisationUrl))) {
      await launchUrl(Uri.parse(authorisationUrl));
    } else {
      print('Could not launch $authorisationUrl');
    }
  }

  Future<void> handleAuthDeepLink(String authorizationCode) async {
    print('code verifier is: $codeVerifier');
    final response = await http.post(
      Uri.parse(tokenEndpoint),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'authorization_code',
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'code': authorizationCode,
        'code_verifier': codeVerifier,
      },
    );

    if (response.statusCode == 200) {
      // Handle the received tokens
      print('Tokens: ${response.body}');
    } else {
      // Handle errors
      print('Error: ${response.body}');
    }
  }
}

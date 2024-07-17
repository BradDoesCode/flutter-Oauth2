import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:oauthtest/authentication.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final appLinks = AppLinks();
  late final OAuthService _oAuthService;

  @override
  void initState() {
    super.initState();
    _oAuthService = OAuthService();
    _setupDeepLinkListener();
    _oAuthService.initiateAuthProcess();
  }

  void _setupDeepLinkListener() {
    appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null &&
          uri.toString().startsWith('com.oauthtest://callback')) {
        // Extract the authorization code from the query parameters
        String? code = uri.queryParameters['code'];
        if (code != null) {
          // If the code exists, pass it to the handleAuthDeepLink method
          _oAuthService.handleAuthDeepLink(code);
        } else {
          print('No code found in the uri');
        }
      } else {
        print('URI is null or does not match expected pattern. URI: $uri');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'OAuth2.0 with PKCE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'authentication pkce test application',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'pages/home.dart';
import 'pages/explore.dart';
import 'pages/login.dart';
import 'pages/welcome.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  } else {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Firebase.initializeApp();
    } else {
      throw UnsupportedError('This app is only configured for Web and Android.');
    }
  }

  // If a user is already signed in (e.g. after a web redirect sign-in),
  // start the app on the Welcome page so the user isn't shown Home.
  final bool signedIn = FirebaseAuth.instance.currentUser != null;
  final String initial = signedIn ? WelcomePage.routeName : '/';

  runApp(MainApp(initialRoute: initial));
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  const MainApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Developer Portfolio — Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: HomePage.primaryButtonColor,
        scaffoldBackgroundColor: HomePage.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: HomePage.accentPurple,
          primary: HomePage.primaryButtonColor,
          background: HomePage.white,
          onPrimary: Colors.white,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Wrap the whole app with ExitGuard using builder so it is applied globally
      builder: (context, child) => ExitGuard(child: child ?? const SizedBox.shrink()),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const HomePage(),
        ExplorePage.routeName: (context) => const ExplorePage(),
        LoginPage.routeName: (context) => const LoginPage(),
        WelcomePage.routeName: (context) => const WelcomePage(),
      },
    );
  }
}

/// ExitGuard prevents accidental app exits by requiring a double-back (or
/// double-swipe back gesture) at the root to actually close the app.
/// It allows normal back navigation within the app (popping routes) but only
/// exits the app if the user performs the back gesture twice within the
/// configured interval. Because ExitGuard is applied in the MaterialApp
/// `builder`, it is active across all pages.
class ExitGuard extends StatefulWidget {
  final Widget child;
  const ExitGuard({super.key, required this.child});

  @override
  State<ExitGuard> createState() => _ExitGuardState();
}

class _ExitGuardState extends State<ExitGuard> {
  DateTime? _lastBackPressed;
  static const Duration _exitThreshold = Duration(seconds: 2);

  Future<bool> _onWillPop() async {
    // If there is somewhere to pop inside the Navigator stack, allow it.
    // This keeps normal in-app back navigation unaffected.
    if (Navigator.of(context).canPop()) {
      return true;
    }

    final now = DateTime.now();
    if (_lastBackPressed == null || now.difference(_lastBackPressed!) > _exitThreshold) {
      _lastBackPressed = now;

      // Show a toast asking the user to swipe/back again to exit.
      Fluttertoast.showToast(
        msg: 'Swipe back again to exit the app',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      return false;
    }

    // Double-swipe (or double back) detected within threshold — allow exit.
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the app content in a WillPopScope so we can intercept back gestures app-wide.
    return WillPopScope(
      onWillPop: _onWillPop,
      child: widget.child,
    );
  }
}
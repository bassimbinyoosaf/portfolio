import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'home.dart';
import 'welcome.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  bool _remember = false;

  bool _submitted = false;
  bool _emailTyping = false;
  bool _passwordTyping = false;

  final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: <String>['email', 'profile']);

  static const String demoEmail = 'demo@gmail.com';
  static const String demoPassword = 'demo123';

  // When true, authStateChanges listener will navigate to Welcome on next non-null user.
  // Set only before calling signInWithRedirect to avoid auto-redirect on app start.
  bool _shouldRedirectOnSignIn = false;
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && _shouldRedirectOnSignIn && mounted) {
        _shouldRedirectOnSignIn = false;
        Navigator.of(context)
            .pushNamedAndRemoveUntil(WelcomePage.routeName, (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _showToast(String msg) async {
    await Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Future<void> _signInWithEmail() async {
    setState(() {
      _submitted = true;
      _emailTyping = false;
      _passwordTyping = false;
    });

    if (!_formKey.currentState!.validate()) return;

    final enteredEmail = _emailCtrl.text.trim();
    final enteredPass = _passwordCtrl.text;

    if (enteredEmail.toLowerCase() != demoEmail ||
        enteredPass != demoPassword) {
      await _showToast(
          'Invalid credentials. Use the demo account shown below or sign in with Google.');
      return;
    }

    setState(() => _loading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      await _showToast('Signed in as $enteredEmail');

      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(WelcomePage.routeName, (route) => false);
      }
    } catch (e) {
      await _showToast('Sign-in failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Google sign-in:
  // - web: try popup, fallback to redirect (set _shouldRedirectOnSignIn before redirect)
  // - mobile: clear sessions so account chooser appears, then sign in
  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});

        try {
          // Try popup first
          final userCredential =
              await FirebaseAuth.instance.signInWithPopup(provider);
          final user = userCredential.user;
          if (user == null) {
            await _showToast('Google sign-in cancelled or failed');
            return;
          }

          // Popup succeeded: navigate immediately
          if (mounted) {
            await _showToast('Welcome, ${user.displayName ?? user.email}');
            Navigator.of(context).pushNamedAndRemoveUntil(
                WelcomePage.routeName, (route) => false);
          }
          return;
        } on FirebaseAuthException catch (e) {
          // Fallback to redirect for popup-blocked and related errors
          if (e.code == 'auth/popup-blocked' ||
              e.code == 'auth/cancelled-popup-request' ||
              e.code == 'auth/popup-closed-by-user') {
            _shouldRedirectOnSignIn = true;
            await FirebaseAuth.instance.signInWithRedirect(provider);
            // Page will reload; the authStateChanges listener will navigate after redirect completes.
            return;
          }
          rethrow;
        }
      }

      // Mobile (Android): clear previous sessions so account chooser appears
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        await _showToast('Google sign-in cancelled');
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        await _showToast('Google sign-in failed');
        return;
      }

      if (mounted) {
        await _showToast('Welcome, ${user.displayName ?? user.email}');
        Navigator.of(context)
            .pushNamedAndRemoveUntil(WelcomePage.routeName, (route) => false);
      }
    } catch (e, st) {
      // Print to console for debugging and show toast
      // ignore: avoid_print
      print('Google sign-in error: $e\n$st');
      await _showToast('Google sign-in failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _emailValidator(String? v) {
    if (!_submitted) return null;
    if (_emailTyping) return null;

    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(s)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? v) {
    if (!_submitted) return null;
    if (_passwordTyping) return null;

    final s = v ?? '';
    if (s.isEmpty) return 'Please enter your password';
    if (s.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final wide = mq.size.width >= 720;

    final TextStyle displaySmall = Theme.of(context)
            .textTheme
            .displaySmall
            ?.copyWith(
              color: HomePage.primaryButtonColor,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ) ??
        TextStyle(
          color: HomePage.primaryButtonColor,
          fontSize: wide ? 28 : 22,
          fontWeight: FontWeight.w900,
          height: 1.0,
        );

    return Scaffold(
      backgroundColor: HomePage.white,
      appBar: AppBar(
        backgroundColor: HomePage.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        toolbarHeight: wide ? 96 : 72,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
          child: Text('Login', style: displaySmall),
        ),
        actions: [
          IconButton(
            tooltip: 'Close',
            iconSize: 28.0,
            splashRadius: 22.0,
            icon: const Icon(Icons.close_rounded),
            color: HomePage.black,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: wide ? 720 : double.infinity),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Builder(builder: (_) {
                      final double containerSize = wide ? 140 : 120;
                      final double iconSize = wide ? 88 : 72;
                      return Container(
                        width: containerSize,
                        height: containerSize,
                        decoration: BoxDecoration(
                          color: HomePage.accentPurple.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Icon(Icons.login_rounded,
                              size: iconSize, color: HomePage.primaryButtonColor),
                        ),
                      );
                    }),
                    const SizedBox(height: 18),
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: _emailValidator,
                            onChanged: (v) {
                              if (!_emailTyping && _submitted) {
                                setState(() => _emailTyping = true);
                              } else if (!_submitted) {
                                setState(() {});
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.key_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _obscure ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: _passwordValidator,
                            onChanged: (v) {
                              if (!_passwordTyping && _submitted) {
                                setState(() => _passwordTyping = true);
                              } else if (!_submitted) {
                                setState(() {});
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(
                                value: _remember,
                                onChanged: (v) => setState(() => _remember = v ?? false),
                              ),
                              const SizedBox(width: 6),
                              const Text('Remember me'),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  _showToast('Forgot password flow not implemented');
                                },
                                child: const Text('Forgot?'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _signInWithEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HomePage.primaryButtonColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                    )
                                  : const Text('Sign in'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('or', style: TextStyle(color: Colors.grey[600])),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loading ? null : _signInWithGoogle,
                        icon: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                          width: 22,
                          height: 22,
                          errorBuilder: (_, __, ___) => const Icon(Icons.login, size: 22),
                        ),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: HomePage.primaryButtonColor,
                              fontSize: wide ? 16 : 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          foregroundColor: HomePage.primaryButtonColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: HomePage.accentPurple.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: HomePage.accentPurple.withOpacity(0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Demo account (email/password sign-in):', style: TextStyle(fontWeight: FontWeight.w700)),
                          SizedBox(height: 6),
                          Text('EMAIL: demo@gmail.com', style: TextStyle(fontFamily: 'monospace')),
                          Text('PASSWORD: demo123', style: TextStyle(fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
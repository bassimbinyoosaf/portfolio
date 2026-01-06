import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './home.dart';
import './developer_profile.dart';

/// WelcomePage — same UI & placement as HomePage, but:
/// - secondary button is "Dev Profile" and opens DeveloperProfilePage
/// - small glassy helper overlay removed
/// - "Welcome, <username> 👋" chip placed above the card
/// - square message chip below buttons
/// - page-level scrolling only when needed
/// - icon-only sign out placed inline with the header text
///
/// Important behavior:
/// - Explicit sign-out is only performed via the sign-out button (with confirmation).
/// - Back (edge) swipe on WelcomePage will exit the app (SystemNavigator.pop) and
///   will NOT sign the user out.
class WelcomePage extends StatelessWidget {
  static const String routeName = '/welcome';

  const WelcomePage({super.key});

  String _displayName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Guest';
    final name = user.displayName ?? user.email ?? user.uid;
    if (name == null || name.isEmpty) return 'User';
    final parts = name.split(' ');
    return parts.isNotEmpty ? parts.first : name;
  }

  /// Sign out and navigate to the app's registered home route ('/').
  /// Using named navigation ensures the route stack is replaced consistently.
  Future<void> _signOutAndGoHome(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // ignore sign out errors for now
    }
    // Use named route to reset navigation stack to HomePage (registered as '/')
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  /// Show a confirmation dialog before signing out. This prevents accidental
  /// sign-outs caused by edge gestures or accidental taps.
  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final mq = MediaQuery.of(ctx);
        final wide = mq.size.width >= 720;
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out?'),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel', style: TextStyle(color: HomePage.primaryButtonColor)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              // Ensure the button's text is visible by setting the foregroundColor (text/icon color).
              style: ElevatedButton.styleFrom(
                backgroundColor: HomePage.primaryButtonColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _signOutAndGoHome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final wide = mq.size.width >= 720;

    final double headerH2 = wide ? 22 : 20;
    final double accentWidth = wide ? 9 : 7;

    final double titleSize = wide ? 34 : 22;
    final double descSize = wide ? 16 : 14;

    final double logoSize = wide ? 320 : 240;
    final double baseCircleSize = logoSize * 0.9;

    final double headerToCardGap = wide ? 28 : 18;

    final TextStyle headerDisplayLarge = Theme.of(context)
            .textTheme
            .displayLarge
            ?.copyWith(color: HomePage.bgDeepTeal, fontWeight: FontWeight.w900, height: 1.02, letterSpacing: 0.2) ??
        TextStyle(color: HomePage.bgDeepTeal, fontSize: wide ? 57 : 40, fontWeight: FontWeight.w900, height: 1.02, letterSpacing: 0.2);

    final TextStyle displaySmall =
        Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: HomePage.black) ??
            TextStyle(fontSize: titleSize, fontWeight: FontWeight.w900, color: HomePage.black);

    final TextStyle descStyle = TextStyle(
      color: const Color(0xFF2B2B2B),
      fontSize: descSize,
      height: 1.65,
      fontWeight: FontWeight.w500,
    );

    final double paragraphWidthFactor = wide ? 0.6 : 0.92;
    final double contentMaxWidth = wide ? 1100 : 760;

    final String firstName = _displayName();

    // Wrap the page in a WillPopScope that exits the app when user performs
    // back (edge) swipe at this route. This prevents any unintended logout
    // side-effects and ensures the app simply closes.
    return WillPopScope(
      onWillPop: () async {
        // Exit the app without signing out.
        // Using SystemNavigator.pop() closes the app on Android.
        try {
          SystemNavigator.pop();
        } catch (_) {
          // If SystemNavigator.pop is not available, fall back to allowing the pop.
          return true;
        }
        // We handled the exit; do not propagate pop further.
        return false;
      },
      child: Scaffold(
        backgroundColor: HomePage.white,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, viewportConstraints) {
            // Scroll only when needed; ensure minHeight = viewport to avoid overflow
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header (same as HomePage) with sign out icon that requires confirmation
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentMaxWidth),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: IntrinsicHeight(
                              // align to start so icon lines up with the "Developer" line
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: accentWidth,
                                    decoration: BoxDecoration(
                                      color: HomePage.accentPurple,
                                      borderRadius: BorderRadius.circular(accentWidth),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x22000000),
                                          offset: Offset(0, 6),
                                          blurRadius: 12,
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Semantics(
                                          header: true,
                                          child: Text('Developer Portfolio', style: headerDisplayLarge),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Flutter',
                                          style: TextStyle(
                                            color: HomePage.neutralGray,
                                            fontSize: headerH2,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Icon-only sign out (no background) — requires confirmation dialog.
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                      tooltip: 'Sign out',
                                      splashRadius: 28,
                                      icon: Icon(
                                        Icons.logout,
                                        size: 32,
                                        color: HomePage.black,
                                      ),
                                      onPressed: () => _confirmSignOut(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: headerToCardGap - 12),

                    // Main centered area (fixed-card-height relative to viewport)
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: wide ? 56 : 24,
                            vertical: wide ? 36 : 24,
                          ),
                          child: Builder(builder: (ctx) {
                            // Choose a cardHeight relative to viewport but bounded
                            final double cardHeight = (viewportConstraints.maxHeight * (wide ? 0.78 : 0.72))
                                .clamp(360.0, viewportConstraints.maxHeight);

                            // compute safe circle size
                            const double reservedForNonCircle = 220.0;
                            double computedCircle = (cardHeight - reservedForNonCircle).clamp(64.0, baseCircleSize);
                            if (computedCircle.isNaN || computedCircle <= 0) computedCircle = 72.0;

                            // Increased gap between card and buttons to move buttons down a bit
                            const double gapCardToButtons = 28.0;
                            const double gapButtonsToMessage = 32.0;

                            return SizedBox(
                              height: cardHeight,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Column inside a bounded height - safe to use Expanded here
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Glass card: takes available internal space
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                            child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: wide ? 36 : 20,
                                                vertical: wide ? 28 : 20,
                                              ),
                                              decoration: BoxDecoration(
                                                color: HomePage.glassTint.withOpacity(0.16),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: HomePage.glassTint.withOpacity(0.28),
                                                  width: 1.0,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.04),
                                                    blurRadius: 18,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(height: 6),
                                                  Container(
                                                    width: computedCircle,
                                                    height: computedCircle,
                                                    decoration: BoxDecoration(
                                                      color: HomePage.accentPurple.withOpacity(0.10),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.developer_mode_rounded,
                                                        size: computedCircle * 0.6,
                                                        color: HomePage.primaryButtonColor,
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(height: 14),

                                                  Text(
                                                    'Flutter Developer Portfolio',
                                                    style: displaySmall,
                                                    textAlign: TextAlign.center,
                                                  ),

                                                  const SizedBox(height: 16),

                                                  FractionallySizedBox(
                                                    widthFactor: paragraphWidthFactor,
                                                    child: Text(
                                                      'Signed-in demo — explore protected\nfeatures and personalized UI.',
                                                      style: descStyle.copyWith(height: 1.3),
                                                      textAlign: TextAlign.center,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: gapCardToButtons),

                                      // Buttons (Wrap like HomePage)
                                      Center(
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 14,
                                          runSpacing: 12,
                                          children: [
                                            ElevatedButton.icon(
                                              style: HomePage.primaryButtonStyle(),
                                              onPressed: () {
                                                Navigator.of(context).pushNamed('/explore');
                                              },
                                              icon: const Icon(Icons.explore_outlined, size: 18),
                                              label: const Text('Explore Portfolio'),
                                            ),
                                            OutlinedButton.icon(
                                              style: HomePage.secondaryButtonStyle(),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(builder: (_) => const DeveloperProfilePage()),
                                                );
                                              },
                                              icon: Icon(Icons.developer_mode_outlined,
                                                  size: 18, color: HomePage.primaryButtonColor),
                                              label: const Text('Dev Profile'),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: gapButtonsToMessage),

                                      // Square-ish message chip centered below buttons
                                      Center(
                                        child: Container(
                                          constraints: const BoxConstraints(minWidth: 200),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: HomePage.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade300),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.03),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            'You are viewing a signed-in demo environment',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: wide ? 13 : 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 6),
                                    ],
                                  ),

                                  // Welcome chip above card (outside)
                                  Positioned(
                                    top: -20,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.92),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          'Welcome, $firstName 👋',
                                          style: TextStyle(
                                            color: HomePage.primaryButtonColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: wide ? 15 : 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
import 'dart:ui';

import 'package:flutter/material.dart';

/// HomePage: header and card widths aligned; reduced the vertical space
/// between the heading and the card previously. The helper message
/// "No account required to explore" is inside a small glassy card and
/// positioned below the buttons using an absolute positioned overlay so the
/// buttons remain exactly where they were. Buttons keep the same height and
/// radius. Both buttons now navigate to named routes:
/// - Explore button -> '/explore'
/// - Login button -> '/login'
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Centralized palette (unchanged)
  static const Color bgDeepTeal = Color(0xFF1F4A52);
  static const Color primaryButtonColor = Color(0xFF163D44);
  static const Color accentPurple = Color(0xFF6D76FF);
  static const Color neutralGray = Color(0xFFB7B7B7);
  static const Color black = Color(0xFF000000);
  static const Color white = Colors.white;

  // Glass tint color requested
  static const Color glassTint = Color(0xFFD3D6FF);

  // Shared corner radius for both buttons so shapes match
  static const double _buttonRadius = 28.0;

  // Ensure both buttons use exactly the same HEIGHT and shape but keep width flexible.
  static const double _buttonHeight = 50.0;
  static const EdgeInsets _buttonPadding = EdgeInsets.symmetric(horizontal: 18, vertical: 12);

  // Primary filled button: height unified, width left flexible
  static ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryButtonColor,
      foregroundColor: white,
      minimumSize: Size(0, _buttonHeight), // height enforced, width flexible
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      padding: _buttonPadding,
    );
  }

  // Secondary (white) button with teal text — same height and radius, width flexible
  static ButtonStyle secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      backgroundColor: white,
      foregroundColor: primaryButtonColor,
      minimumSize: Size(0, _buttonHeight), // height enforced, width flexible
      side: const BorderSide(color: Color(0x11000000)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      padding: _buttonPadding,
    ).merge(
      ButtonStyle(
        overlayColor:
            MaterialStateProperty.resolveWith((_) => primaryButtonColor.withOpacity(0.06)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final wide = mq.size.width >= 720;

    // Header sizes
    final double headerH2 = wide ? 22 : 20;
    final double accentWidth = wide ? 9 : 7;

    // Card/content sizes
    final double titleSize = wide ? 34 : 22;
    final double descSize = wide ? 16 : 14;

    // Developer icon baseline size
    final double logoSize = wide ? 320 : 240;
    final double circleSize = logoSize * 0.9;

    // Reduced gap between header and content (changed only this earlier)
    final double headerToCardGap = wide ? 28 : 18;

    // Use displayLarge from the Material text theme for the main header.
    final TextStyle headerDisplayLarge = Theme.of(context)
            .textTheme
            .displayLarge
            ?.copyWith(color: bgDeepTeal, fontWeight: FontWeight.w900, height: 1.02, letterSpacing: 0.2) ??
        TextStyle(color: bgDeepTeal, fontSize: wide ? 57 : 40, fontWeight: FontWeight.w900, height: 1.02, letterSpacing: 0.2);

    final TextStyle displaySmall =
        Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: black) ??
            TextStyle(fontSize: titleSize, fontWeight: FontWeight.w900, color: black);

    final TextStyle descStyle = TextStyle(
      color: const Color(0xFF2B2B2B),
      fontSize: descSize,
      height: 1.65,
      fontWeight: FontWeight.w500,
    );

    // Width factor for paragraph readability
    final double paragraphWidthFactor = wide ? 0.6 : 0.92;

    // CENTRAL CONTENT WIDTH: both header and card will use this same max width,
    // ensuring their left/right edges align visually.
    final double contentMaxWidth = wide ? 1100 : 760;

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          // keep original contentHeight baseline (no height increase)
          final double contentHeight = (constraints.maxHeight) * (wide ? 0.78 : 0.72);

          return Column(
            children: [
              // Header wrapped with the same centered ConstrainedBox used by the card
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Padding(
                      // keep the same horizontal padding visually as before
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: accentWidth,
                              decoration: BoxDecoration(
                                color: accentPurple,
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
                                    child: Text(
                                      'Developer Portfolio',
                                      style: headerDisplayLarge,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Reverted "Flutter" subheading color is neutral gray
                                  Text(
                                    'Flutter',
                                    style: TextStyle(
                                      color: neutralGray,
                                      fontSize: headerH2,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Reduced spacing between header and card (only this changed earlier)
              SizedBox(height: headerToCardGap - 12),

              // Content area (formerly the card) — now centered and using the same max width
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: SizedBox(
                        height: contentHeight.clamp(360.0, constraints.maxHeight),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: wide ? 56 : 24,
                            vertical: wide ? 36 : 24,
                          ),
                          child: LayoutBuilder(builder: (ctx, cardConstraints) {
                            // Wrap original Column in a Stack so we can absolutely position the helper
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // ORIGINAL FLOW: untouched column — buttons stay exactly where they were
                                ConstrainedBox(
                                  constraints: BoxConstraints(minHeight: cardConstraints.maxHeight),
                                  child: IntrinsicHeight(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // GLASS CARD: wrapped around icon/title/paragraph
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                            child: Container(
                                              width: double.infinity,
                                              // height unchanged — no minHeight forced
                                              padding: EdgeInsets.symmetric(
                                                horizontal: wide ? 36 : 20,
                                                vertical: wide ? 28 : 20,
                                              ),
                                              decoration: BoxDecoration(
                                                color: glassTint.withOpacity(0.16),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: glassTint.withOpacity(0.28),
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
                                                  // Developer icon (large circle)
                                                  Container(
                                                    width: circleSize,
                                                    height: circleSize,
                                                    decoration: BoxDecoration(
                                                      color: accentPurple.withOpacity(0.10),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.developer_mode_rounded,
                                                        size: circleSize * 0.6,
                                                        color: primaryButtonColor,
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(height: 14),

                                                  // Secondary title (kept for product title)
                                                  Text(
                                                    'Flutter Portfolio App',
                                                    style: displaySmall,
                                                    textAlign: TextAlign.center,
                                                  ),

                                                  const SizedBox(height: 16),

                                                  // Paragraph constrained for readability
                                                  FractionallySizedBox(
                                                    widthFactor: paragraphWidthFactor,
                                                    child: Text(
                                                      'A real-world Flutter app showcasing\nclean UI, architecture, and scalability.',
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

                                        const Spacer(),

                                        // Keep spacing above action buttons (unchanged)
                                        const SizedBox(height: 8),

                                        // Actions — buttons share the same height & radius and now navigate
                                        Center(
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            spacing: 14,
                                            runSpacing: 12,
                                            children: [
                                              ElevatedButton.icon(
                                                style: primaryButtonStyle(),
                                                onPressed: () {
                                                  Navigator.of(context).pushNamed('/explore');
                                                },
                                                icon: const Icon(Icons.explore_outlined, size: 18),
                                                label: const Text('Explore Portfolio'),
                                              ),
                                              OutlinedButton.icon(
                                                style: secondaryButtonStyle(),
                                                onPressed: () {
                                                  Navigator.of(context).pushNamed('/login');
                                                },
                                                icon: Icon(Icons.login, size: 18, color: primaryButtonColor),
                                                label: const Text('Login (Demo)'),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Preserve original post-action spacing exactly
                                        const SizedBox(height: 10),

                                        // Keep a little bottom spacing so content doesn't touch the bottom
                                        const SizedBox(height: 36),
                                      ],
                                    ),
                                  ),
                                ),

                                // ABSOLUTE: Small glassy helper card positioned below the buttons.
                                // It's absolutely positioned inside the same stack so it does NOT affect column flow.
                                Positioned(
                                  // maintains the previously applied breathable offset
                                  bottom: -18,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: glassTint.withOpacity(0.14),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: glassTint.withOpacity(0.22),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Text(
                                            'No account required to explore',
                                            style: TextStyle(
                                              color: primaryButtonColor,
                                              fontSize: wide ? 15 : 14,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.2,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        }),
      ),
    );
  }
}
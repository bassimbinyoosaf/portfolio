import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import './home.dart';

class ProjectDetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String details; // project-specific longer details (multi-paragraph)
  final IconData icon;
  final bool ongoing;
  final String? imageAsset; // optional asset image to show for the project
  final List<String> skills; // key skills to show as chips
  final List<String> technicalHighlights; // longer technical highlights

  const ProjectDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.details,
    required this.icon,
    this.ongoing = false,
    this.imageAsset,
    this.skills = const <String>[],
    this.technicalHighlights = const <String>[],
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> with TickerProviderStateMixin {
  static const double imageCornerRadius = 16.0;

  // Key used to find the on-screen image's RenderBox for the morph animation.
  final GlobalKey _imageKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  AnimationController? _animController;
  Rect? _startRect; // starting rect of the tapped image (global coordinates)
  Rect? _endRect; // target centered rect (Instagram-reels style)

  // Concrete tween types
  RectTween? _rectTween;
  Tween<double>? _radiusTween;

  bool isMobileScreenshotFileName(String? asset) {
    if (asset == null) return false;
    return asset.toLowerCase().endsWith('1.png');
  }

  /// Try to load the asset and obtain its intrinsic aspect ratio (height / width).
  /// Returns null on error or timeout.
  Future<double?> _getImageAspect(String asset) async {
    try {
      final completer = Completer<ImageInfo>();
      final ImageStream stream = AssetImage(asset).resolve(const ImageConfiguration());
      ImageStreamListener? listener;
      listener = ImageStreamListener((ImageInfo info, bool syncCall) {
        if (!completer.isCompleted) completer.complete(info);
        try {
          stream.removeListener(listener!);
        } catch (_) {}
      }, onError: (err, st) {
        if (!completer.isCompleted) completer.completeError(err ?? 'error');
        try {
          stream.removeListener(listener!);
        } catch (_) {}
      });

      stream.addListener(listener);
      final ImageInfo info = await completer.future.timeout(
        const Duration(milliseconds: 400),
        onTimeout: () {
          try {
            stream.removeListener(listener!);
          } catch (_) {}
          throw Exception('timeout');
        },
      );

      final int w = info.image.width;
      final int h = info.image.height;
      // dispose image resource to avoid leaks
      try {
        info.image.dispose();
      } catch (_) {}
      if (w == 0) return null;
      return h / w;
    } catch (_) {
      return null;
    }
  }

  /// Show overlay morph. Computes start rect from the on-screen image, gets
  /// intrinsic aspect, and morphs into a centered "reel-card" sized based on the image's aspect.
  Future<void> _showImageOverlayForAsset(String asset) async {
    if (_overlayEntry != null) return;

    final imageContext = _imageKey.currentContext;
    if (imageContext == null) {
      _insertSimpleOverlay(asset);
      return;
    }

    final renderBox = imageContext.findRenderObject() as RenderBox;
    final topLeft = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    _startRect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);

    // obtain intrinsic aspect (height / width)
    double? intrinsicAspect = await _getImageAspect(asset).catchError((_) => null);

    if (intrinsicAspect == null) {
      intrinsicAspect = isMobileScreenshotFileName(asset) ? (2340.0 / 1080.0) : (9.0 / 16.0);
    }

    final bool isPortrait = intrinsicAspect >= 1.5;

    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final topPadding = mq.padding.top;
    final bottomPadding = mq.padding.bottom;
    final usableHeight = screenH - topPadding - bottomPadding;

    // Compute end rect sized according to intrinsic aspect while not exceeding constraints.
    double maxWidth = screenW * (screenW > 720 ? 0.72 : 0.92);
    double maxHeight = usableHeight * (isPortrait ? 0.78 : 0.68);

    // Derive width and height so image fits inside maxWidth and maxHeight using aspect (h / w).
    // height = width * aspect => width = min(maxWidth, maxHeight / aspect)
    double targetWidth = (maxHeight / intrinsicAspect).clamp(120.0, maxWidth);
    if (targetWidth > maxWidth) targetWidth = maxWidth;
    double targetHeight = targetWidth * intrinsicAspect;

    // If somehow height exceeds maxHeight, cap it and recompute width.
    if (targetHeight > maxHeight) {
      targetHeight = maxHeight;
      targetWidth = (targetHeight / intrinsicAspect).clamp(120.0, maxWidth);
    }

    final double targetLeft = (screenW - targetWidth) / 2.0;
    final double targetTop = topPadding + (usableHeight - targetHeight) / 2.0;
    _endRect = Rect.fromLTWH(targetLeft, targetTop, targetWidth, targetHeight);

    _rectTween = RectTween(begin: _startRect, end: _endRect);
    _radiusTween = Tween<double>(begin: imageCornerRadius, end: 12.0);

    _animController?.dispose();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    final curve = CurvedAnimation(parent: _animController!, curve: Curves.easeOutCubic);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: curve,
          builder: (c, child) {
            final rect = _rectTween?.evaluate(curve) ?? Rect.zero;
            final radius = _radiusTween?.evaluate(curve) ?? imageCornerRadius;
            final double backdropOpacity = (curve.value * 0.92).clamp(0.0, 0.92);
            final bool interactive = curve.value > 0.92;

            return Stack(
              children: [
                // blurred background using the same image
                Opacity(
                  opacity: backdropOpacity,
                  child: SizedBox.expand(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(asset, fit: BoxFit.cover, gaplessPlayback: true),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16.0 * curve.value, sigmaY: 16.0 * curve.value),
                          child: Container(color: Colors.black.withOpacity(0.18 * curve.value)),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned.fromRect(
                  rect: rect,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: Container(
                      color: Colors.black,
                      child: interactive
                          ? InteractiveViewer(
                              panEnabled: true,
                              minScale: 1.0,
                              maxScale: 3.0,
                              child: Image.asset(
                                asset,
                                fit: BoxFit.contain,
                                width: rect.width,
                                height: rect.height,
                                gaplessPlayback: true,
                              ),
                            )
                          : Image.asset(
                              asset,
                              fit: BoxFit.contain,
                              width: rect.width,
                              height: rect.height,
                              gaplessPlayback: true,
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    Overlay.of(context)!.insert(_overlayEntry!);
    _animController!.forward();
  }

  void _insertSimpleOverlay(String asset) {
    _animController?.dispose();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    final curve = CurvedAnimation(parent: _animController!, curve: Curves.easeOut);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return FadeTransition(
          opacity: curve,
          child: Material(
            color: Colors.black.withOpacity(0.9),
            child: SafeArea(
              child: Center(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Image.asset(asset, fit: BoxFit.contain, gaplessPlayback: true),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context)!.insert(_overlayEntry!);
    _animController!.forward();
  }

  void _hideImageOverlay() {
    if (_overlayEntry == null || _animController == null) return;

    _animController!.reverse().whenComplete(() {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _animController?.dispose();
      _animController = null;
    });
  }

  void _removeOverlayImmediate() {
    if (_overlayEntry == null) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _animController?.dispose();
    _animController = null;
  }

  /// Build framed image sized based on the image's intrinsic aspect ratio.
  /// Uses FutureBuilder to read the asset dimensions and compute a perfect size.
  Widget _framedImageWithIntrinsicSize(
    String asset, {
    required double frameWidth,
    required double maxUsableHeight,
    required bool preferPortraitPhoneFrame,
  }) {
    return FutureBuilder<double?>(
      future: _getImageAspect(asset).timeout(const Duration(milliseconds: 450), onTimeout: () => null),
      builder: (context, snapshot) {
        double? aspect = snapshot.data;
        if (aspect == null) {
          // fallback heuristics
          aspect = isMobileScreenshotFileName(asset) ? (2340.0 / 1080.0) : (9.0 / 16.0);
        }

        final bool isPortrait = aspect >= 1.5;

        // Constraints for display:
        final double maxWidth = frameWidth * (isPortrait ? 0.6 : 0.98);
        final double maxHeight = maxUsableHeight * (isPortrait ? 0.78 : 0.68);

        // compute width & height so the image fits inside these constraints using its intrinsic aspect (h / w)
        double displayWidth = (maxHeight / aspect).clamp(120.0, maxWidth);
        if (displayWidth > maxWidth) displayWidth = maxWidth;
        double displayHeight = displayWidth * aspect;

        if (displayHeight > maxHeight) {
          displayHeight = maxHeight;
          displayWidth = (displayHeight / aspect).clamp(120.0, maxWidth);
        }

        // small safety clamps
        displayWidth = displayWidth.clamp(120.0, frameWidth);
        displayHeight = displayHeight.clamp(80.0, maxUsableHeight);

        // For phone-like frames (1.png) optionally prefer a fixed phone width if requested
        if (preferPortraitPhoneFrame && isPortrait) {
          final double phoneFrameWidth = displayWidth.clamp(160.0, 320.0);
          final double phoneAspect = aspect;
          final double phoneFrameHeight = (phoneFrameWidth * phoneAspect).clamp(180.0, maxUsableHeight * 0.9);
          return Center(
            child: _buildFramedImage(
              asset,
              width: phoneFrameWidth,
              height: phoneFrameHeight,
              fit: BoxFit.cover,
            ),
          );
        }

        // wrap the image in a black container + center so BoxFit.contain fits inside nicely
        return Center(
          child: _buildFramedImageWrapped(
            asset,
            width: displayWidth,
            height: displayHeight,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }

  Widget _buildFramedImageWrapped(
    String asset, {
    required double width,
    required double height,
    required BoxFit fit,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (_) => _showImageOverlayForAsset(asset),
      onLongPressEnd: (_) => _hideImageOverlay(),
      onLongPressCancel: () => _hideImageOverlay(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(imageCornerRadius),
        child: Container(
          key: _imageKey,
          width: width,
          height: height,
          color: Colors.black,
          child: Center(
            child: Image.asset(
              asset,
              fit: fit,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFramedImage(
    String asset, {
    required double width,
    required double height,
    required BoxFit fit,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (_) => _showImageOverlayForAsset(asset),
      onLongPressEnd: (_) => _hideImageOverlay(),
      onLongPressCancel: () => _hideImageOverlay(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(imageCornerRadius),
        child: SizedBox(
          key: _imageKey,
          width: width,
          height: height,
          child: Image.asset(
            asset,
            fit: fit,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController?.dispose();
    _removeOverlayImmediate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final wide = mq.size.width >= 720;

    // Restore headingStyle to use the theme value (same as before),
    // but set its color to the original primary color used elsewhere.
    final TextStyle headingStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: HomePage.primaryButtonColor, // changed to match the previous top heading color
          fontWeight: FontWeight.w900,
        ) ??
        TextStyle(
          color: HomePage.primaryButtonColor,
          fontSize: wide ? 28 : 24,
          fontWeight: FontWeight.w900,
        );

    Widget statusPill() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.orange.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ONGOING',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: wide ? 14.0 : 13.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      );
    }

    final double frameMaxWidth = wide ? mq.size.width * 0.6 : mq.size.width - 32;
    final double frameWidth = frameMaxWidth.clamp(160.0, mq.size.width);
    final double usableHeight = mq.size.height - mq.padding.top - mq.padding.bottom;

    // Increased sizes for content and headings (kept larger per your request)
    final double headingFontSize = wide ? 22.0 : 20.0; // used for section headings
    final double contentFontSize = wide ? 19.0 : 18.0;
    final double detailsFontSize = wide ? 18.0 : 17.0;
    final double highlightFontSize = wide ? 18.0 : 17.0;
    final double chipFontSize = wide ? 16.0 : 15.0;
    final double smallInstructionSize = wide ? 16.0 : 15.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HomePage.white,
        elevation: 0,
        centerTitle: false,
        title: null,
        iconTheme: IconThemeData(color: HomePage.primaryButtonColor),
      ),
      backgroundColor: HomePage.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: HomePage.accentPurple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(widget.icon, color: HomePage.primaryButtonColor, size: 38),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Use the restored headingStyle so the main title color matches the previous top heading color
                        Text(widget.title, style: headingStyle),
                        const SizedBox(height: 8),
                        if (widget.ongoing) statusPill(),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // IMAGE - dynamic sizing according to intrinsic width/height
              if (widget.imageAsset != null) ...[
                Builder(builder: (context) {
                  final asset = widget.imageAsset!;
                  // prefer phone-like smaller frame for 1.png but still base size on intrinsic aspect
                  final preferPhone = asset.toLowerCase().endsWith('1.png');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _framedImageWithIntrinsicSize(
                      asset,
                      frameWidth: frameWidth,
                      maxUsableHeight: usableHeight,
                      preferPortraitPhoneFrame: preferPhone,
                    ),
                  );
                }),

                // small instruction message telling the user how to open zoom (long press)
                const SizedBox(height: 10),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, size: 18, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text(
                        'Long-press and hold image for a better view',
                        style: TextStyle(color: Colors.grey, fontSize: smallInstructionSize),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
              ],

              // skills
              if (widget.skills.isNotEmpty) ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.skills.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: HomePage.accentPurple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: HomePage.accentPurple.withOpacity(0.18)),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          color: HomePage.primaryButtonColor,
                          fontSize: chipFontSize,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
              ],

              // Overview
              Text(
                'Overview',
                style: TextStyle(
                  color: HomePage.black,
                  fontSize: headingFontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.description,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: contentFontSize,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Details (project-specific, inserted from ExplorePage)
              Text(
                'Details',
                style: TextStyle(
                  color: HomePage.black,
                  fontSize: headingFontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.details,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: detailsFontSize,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),

              // Technical Highlights (separate from Details)
              if (widget.technicalHighlights.isNotEmpty) ...[
                Text(
                  'Technical Highlights',
                  style: TextStyle(
                    color: HomePage.black,
                    fontSize: headingFontSize,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.technicalHighlights.map((h) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0, right: 12.0),
                            child: Icon(Icons.brightness_1, size: 10, color: Colors.grey[700]),
                          ),
                          Expanded(
                            child: Text(
                              h,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: highlightFontSize,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
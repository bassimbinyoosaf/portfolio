import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import './home.dart';
import './welcome.dart';

/// Developer Profile — minor typographic update and navigation change:
/// - AppBar now uses the same "Close (X)" button approach as Explore page.
/// - The close button navigates to the Welcome page and there is no back icon.
class DeveloperProfilePage extends StatelessWidget {
  const DeveloperProfilePage({super.key});

  // Static minimal portfolio info (concise).
  static const String _name = 'Bassim Bin Yoosaf';
  static const String _role = 'MCA Student • Flutter · Android · iOS';
  static const String _shortBio =
      'Passionate Flutter developer focused on building clean, accessible, and scalable mobile experiences. Open to internships and freelance work.';
  static const String _email = 'bassimbinyoosaf23@gmail.com';
  static const String _location = 'Calicut, Kerala, India';
  static const String _linkedin = 'https://www.linkedin.com/in/bassim-bin-yoosaf';
  static const String _github = 'https://www.github.com/bassimbinyoosaf';

  // Top skills to display as chips (concise set).
  static const List<String> _topSkills = [
    'Flutter',
    'Dart',
    'Firebase',
    'REST APIs',
    'UI/UX',
  ];

  // A couple of short highlights (not a full project list).
  static const List<String> _highlights = [
    'Built responsive, production-like Flutter apps with Firebase integration.',
    'Experience with authentication, real-time data, and clean state management.',
  ];

  // Resume asset path (as requested)
  static const String _resumeAsset = 'assets/files/resume.pdf';

  // Open a generic URL (external application)
  Future<void> _openUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  // Open mail composer
  Future<void> _openMail(BuildContext context) async {
    final Uri mailto = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {'subject': ''},
    );
    try {
      if (!await launchUrl(mailto)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open mail app')));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open mail app')));
    }
  }

  // Open the bundled resume:
  // - Web: resolve asset URL and open in browser
  // - Mobile/Desktop: copy asset bytes to a temporary file and open it with the platform viewer
  Future<void> _openResume(BuildContext context) async {
    try {
      if (kIsWeb) {
        // On web assets are served; resolve and open
        final Uri uri = Uri.base.resolve(_resumeAsset);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open resume')));
        }
        return;
      }

      // Non-web: copy asset to temp and open
      final bytes = await rootBundle.load(_resumeAsset);
      final list = bytes.buffer.asUint8List();

      final tmpDir = await getTemporaryDirectory();
      final file = File('${tmpDir.path}/resume.pdf');

      await file.writeAsBytes(list, flush: true);

      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open resume: ${result.message}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to open resume')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bool wide = mq.size.width >= 720;

    // 1) Top heading style — use same approach as Explore page (displaySmall)
    final TextStyle displaySmall =
        Theme.of(context).textTheme.displaySmall?.copyWith(
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

    // Body size
    final double bodySize = wide ? 18.0 : 17.0;
    final TextStyle bodyStyle = TextStyle(
      color: Colors.grey[800],
      fontSize: bodySize,
      height: 1.6,
    );

    // Role style
    final TextStyle roleStyle = TextStyle(
      color: Colors.grey[800],
      fontSize: wide ? 16 : 15,
      fontWeight: FontWeight.w700,
    );

    // Name uses headlineMedium from theme (headline medium size), fallback included.
    final TextStyle nameStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: HomePage.primaryButtonColor,
          fontWeight: FontWeight.w900,
        ) ??
        TextStyle(
          color: HomePage.primaryButtonColor,
          fontWeight: FontWeight.w900,
          fontSize: wide ? 24 : 20,
        );

    return Scaffold(
      backgroundColor: HomePage.white,
      appBar: AppBar(
        backgroundColor: HomePage.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, // remove back icon
        titleSpacing: 0,
        toolbarHeight: wide ? 96 : 72,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
          child: Text('Developer Profile', style: displaySmall),
        ),
        actions: [
          IconButton(
            tooltip: 'Close',
            iconSize: 28.0,
            splashRadius: 22.0,
            icon: const Icon(Icons.close_rounded),
            color: HomePage.black,
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(WelcomePage.routeName, (route) => false);
            },
          ),
        ],
        iconTheme: IconThemeData(color: HomePage.primaryButtonColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: wide ? 32.0 : 16.0, vertical: 20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wide ? 980 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top hero: responsive layout with logo placed next to the name (wide)
                  // or above the name (narrow).
                  Container(
                    decoration: BoxDecoration(
                      color: HomePage.bgDeepTeal.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          HomePage.bgDeepTeal.withOpacity(0.03),
                          HomePage.accentPurple.withOpacity(0.02)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Larger logo to the left of the name
                              _profileLogo(wide),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_name, style: nameStyle),
                                    const SizedBox(height: 6),
                                    Text(_role, style: roleStyle),
                                    const SizedBox(height: 10),
                                    Text(
                                      _shortBio,
                                      style: bodyStyle.copyWith(color: Colors.grey[700]),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _profileLogo(wide),
                              const SizedBox(height: 12),
                              Text(_name, style: nameStyle, textAlign: TextAlign.center),
                              const SizedBox(height: 6),
                              Text(_role, style: roleStyle, textAlign: TextAlign.center),
                              const SizedBox(height: 10),
                              Text(
                                _shortBio,
                                style: bodyStyle.copyWith(color: Colors.grey[700]),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 18),

                  // Contact & actions card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                      child: Column(
                        children: [
                          // contact items: email + location (phone removed per request)
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _contactItem(Icons.email_outlined, _email, bodyStyle),
                              _contactItem(Icons.location_on_outlined, _location, bodyStyle),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // links (tappable)
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _linkItem(Icons.link, _linkedin, () => _openUrl(_linkedin, context), bodyStyle),
                              _linkItem(Icons.code, _github, () => _openUrl(_github, context), bodyStyle),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _openResume(context),
                                // Changed: "View CV" with a visibility icon
                                icon: const Icon(Icons.visibility_outlined, size: 18),
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Text('View CV', style: bodyStyle.copyWith(color: Colors.white)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HomePage.primaryButtonColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () => _openMail(context),
                                icon: const Icon(Icons.mail_outline, size: 18),
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Text('Contact', style: bodyStyle.copyWith(color: HomePage.primaryButtonColor)),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  foregroundColor: HomePage.primaryButtonColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Two-column responsive area: left = skills & highlights, right = small info cards
                  LayoutBuilder(builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 720;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column: skills & highlights (primary)
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _sectionCard(
                                  title: 'Top Skills',
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _topSkills.map((s) => _skillChip(s)).toList(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _sectionCard(
                                  title: 'Highlights',
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: _highlights.map((h) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.only(top: 6, right: 12),
                                              decoration: BoxDecoration(
                                                color: HomePage.accentPurple,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Expanded(child: Text(h, style: bodyStyle)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Right column: small info cards (availability / quick facts)
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _infoTile('Availability', 'Open to internships & freelance', bodyStyle),
                                const SizedBox(height: 10),
                                _infoTile('Experience', 'Flutter apps • Firebase • Frontend', bodyStyle),
                                const SizedBox(height: 10),
                                _infoTile('Languages', 'English, Malayalam, Hindi', bodyStyle),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    // Narrow: stacked
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _sectionCard(
                          title: 'Top Skills',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _topSkills.map((s) => _skillChip(s)).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _sectionCard(
                          title: 'Highlights',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _highlights.map((h) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 6, right: 12),
                                      decoration: BoxDecoration(
                                        color: HomePage.accentPurple,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(child: Text(h, style: bodyStyle)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _infoTile('Availability', 'Open to internships & freelance', bodyStyle),
                        const SizedBox(height: 10),
                        _infoTile('Experience', 'Flutter apps • Firebase • Frontend', bodyStyle),
                        const SizedBox(height: 10),
                        _infoTile('Languages', 'English, Malayalam, Hindi', bodyStyle),
                      ],
                    );
                  }),

                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Stylized temporary profile logo (enlarged)
  Widget _profileLogo(bool wide) {
    final double size = wide ? 180 : 140;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [HomePage.primaryButtonColor, HomePage.accentPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: HomePage.primaryButtonColor.withOpacity(0.18), blurRadius: 22, offset: const Offset(0, 10)),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.developer_mode_rounded, color: Colors.white, size: wide ? 64 : 48),
            const SizedBox(height: 8),
            Text(
              'BSM',
              style: TextStyle(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w900, fontSize: wide ? 20 : 16),
            ),
          ],
        ),
      ),
    );
  }

  // Contact item used in the contact card (phone removed)
  Widget _contactItem(IconData icon, String text, TextStyle bodyStyle) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 10),
        Flexible(child: Text(text, style: bodyStyle.copyWith(color: Colors.black87), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  // Link item used for LinkedIn / GitHub (tappable)
  Widget _linkItem(IconData icon, String text, VoidCallback onTap, TextStyle bodyStyle) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: Colors.black45),
          const SizedBox(width: 10),
          Flexible(child: Text(text, style: bodyStyle.copyWith(color: Colors.black87), overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  // Small elevated section card for skills/highlights
  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: HomePage.primaryButtonColor, fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 10),
          child,
        ]),
      ),
    );
  }

  // Small info tile used in the right column
  Widget _infoTile(String title, String value, TextStyle bodyStyle) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: HomePage.accentPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.info_outline, color: HomePage.primaryButtonColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(value, style: bodyStyle.copyWith(color: Colors.black87)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // Skill chip (larger)
  Widget _skillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: HomePage.accentPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HomePage.accentPurple.withOpacity(0.12)),
      ),
      child: Text(label, style: TextStyle(color: HomePage.primaryButtonColor, fontWeight: FontWeight.w700)),
    );
  }
}
import 'package:flutter/material.dart';
import './home.dart';
import 'project_detail.dart';

/// Explore page — passes details, technical highlights and image asset into ProjectDetailPage.
class ExplorePage extends StatelessWidget {
  static const String routeName = '/explore';

  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final wide = mq.size.width >= 720;

    // Main heading style (uses displaySmall from theme when available)
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

    // Subtitle style
    final TextStyle subtitleStyle = TextStyle(
      color: const Color(0xFF2B2B2B),
      fontSize: wide ? 16 : 14,
      height: 1.25,
      fontWeight: FontWeight.w500,
    );

    // Projects list with concise descriptions and separate "highlights" and "details" data.
    final List<Map<String, Object?>> projects = [
      {
        'title': 'Emotion Detection System',
        'icon': Icons.mood,
        'desc': 'Full‑stack emotion recognition adapting the UX.',
        'details':
            'This project focuses on adapting the user experience based on detected emotional states. '
            'User data and preferences are securely stored in the cloud, allowing the application to personalize suggestions and flows dynamically. '
            'The system demonstrates state-driven UI updates, asynchronous data handling, and integration between frontend logic and backend services. '
            'Special attention is given to clean architecture and scalable feature expansion.',
        'ongoing': true,
        'image': 'assets/images/1.png',
        'skills': ['Flutter', 'Firebase', 'Emotion ML'],
        'highlights': <String>[
          'Emotion-based UI adaptation using state-driven logic',
          'Firebase Authentication for secure user access',
          'Cloud Firestore for storing user data and emotion history',
          'Real-time UI updates based on detected emotional states',
          'Modular Flutter architecture with reusable components',
          'Asynchronous data handling with proper error states',
        ],
      },
      {
        'title': 'Skill & Career Tracking System',
        'icon': Icons.school_outlined,
        'desc': 'Tracks student skills with auth and dashboards.',
        'details':
            'This system enables students to track skills, progress, and career-related data through authenticated dashboards. '
            'The application supports role-based access, allowing different views for users and administrators. '
            'Data is managed through REST APIs with structured database models, ensuring consistency and scalability. '
            'The project emphasizes dashboard-driven design, CRUD operations, and secure session handling.',
        'image': 'assets/images/2.png',
        'skills': ['MongoDB', 'Express', 'React', 'Node'],
        'highlights': <String>[
          'Role-based authentication for students and administrators',
          'RESTful API development using Node.js and Express',
          'MongoDB schema design for skills, progress, and reports',
          'Dashboard-based UI for tracking learning progress',
          'Secure JWT-based session handling',
          'Full CRUD operations with validation and access control',
        ],
      },
      {
        'title': 'Car Sales Platform',
        'icon': Icons.directions_car_outlined,
        'desc': 'Browse, filter and compare cars with an intuitive marketplace UI.',
        'details':
            'The platform allows users to browse, filter, and compare car listings through a responsive single-page application. '
            'It focuses on smooth user interactions, dynamic filtering logic, and clean separation of UI components and services. '
            'The application demonstrates efficient state handling, reusable UI components, and responsive design principles optimized for different screen sizes.',
        'image': 'assets/images/3.png',
        'skills': ['Angular', 'SPA', 'Responsive UI'],
        'highlights': <String>[
          'Component-based Angular single-page application architecture',
          'Dynamic filtering, searching, and comparison features',
          'State management for car listings and user interactions',
          'Fully responsive UI for desktop and mobile devices',
          'REST API integration for fetching and displaying data',
          'Clean separation of components, services, and models',
        ],
      },
      {
        'title': 'College Venue Booking System',
        'icon': Icons.event_available,
        'desc': 'Real‑time booking with admin approval workflows.',
        'details':
            'This system manages venue availability and booking requests with real-time updates. '
            'Users can request bookings, while administrators handle approvals through a controlled workflow. '
            'The backend ensures data consistency using relational database design and server-side validation. '
            'The project highlights booking lifecycle management, access control, and reliable data handling.',
        'image': null,
        'skills': ['PHP', 'MySQL', 'Booking Logic'],
        'highlights': <String>[
          'Relational database design using MySQL',
          'Real-time venue availability checking logic',
          'Admin approval workflow for booking requests',
          'Secure session-based authentication',
          'Server-side validation for booking and user actions',
          'Structured backend logic for managing booking lifecycle',
        ],
      },
      {
        'title': 'Online Voting System',
        'icon': Icons.how_to_vote_outlined,
        'desc': 'Secure online voting with authentication and results.',
        'details':
            'The voting system is designed to conduct secure online elections with authenticated users. '
            'It ensures vote integrity by preventing duplicate submissions and controlling access through backend validation. '
            'Results are calculated and displayed in real time. '
            'The project demonstrates secure authentication, role-based access, and structured data management for election processes.',
        'image': null,
        'skills': ['PHP', 'MySQL', 'Auth & Security'],
        'highlights': <String>[
          'Secure voter and admin authentication system',
          'Controlled vote submission to prevent duplicate voting',
          'Real-time vote counting and result generation',
          'Normalized database schema for elections and voting data',
          'Role-based access control for election management',
          'Backend validation to ensure data integrity',
        ],
      },
    ];

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore Portfolio',
                style: displaySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Browse projects, skills, and how this app is built.',
                style: subtitleStyle,
              ),
            ],
          ),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          // Make the whole content scrollable so the footer is reachable when content is long
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Grid of project cards (title + icon + concise description)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: projects.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: wide ? 3 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: wide ? 1.05 : 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    final icon = project['icon'] as IconData;
                    final title = project['title'] as String;
                    final desc = project['desc'] as String;
                    final details = (project['details'] as String?) ?? '';
                    final ongoing = (project['ongoing'] as bool?) ?? false;
                    final image = project['image'] as String?;
                    final skills = (project['skills'] as List<String>?) ?? <String>[];
                    final highlights = (project['highlights'] as List<String>?) ?? <String>[];

                    return Card(
                      color: HomePage.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Navigate to detail page and pass project info including image asset (if any)
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailPage(
                                title: title,
                                description: desc,
                                details: details,
                                icon: icon,
                                ongoing: ongoing,
                                imageAsset: image,
                                skills: skills,
                                technicalHighlights: highlights,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: HomePage.accentPurple.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Icon(icon, color: HomePage.primaryButtonColor, size: 24),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (ongoing)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.orange.withOpacity(0.18)),
                                        ),
                                        child: Text(
                                          'ONGOING',
                                          style: TextStyle(
                                            color: Colors.orange.shade800,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                title,
                                style: TextStyle(
                                  color: HomePage.black,
                                  fontSize: wide ? 15 : 14,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                desc,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: wide ? 12 : 11,
                                  height: 1.15,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(Icons.keyboard_arrow_right, color: HomePage.accentPurple, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Small spacer then footer message to fill the empty lower area
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "That’s all for now 👋",
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: wide ? 16 : 15,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "More projects and improvements are coming.",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: wide ? 15 : 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Extra bottom padding so footer isn't flush to the screen edge
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
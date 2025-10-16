import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyA8X9s_ZkhYH6gFzw1HMOoxSHZrNwUc",
      authDomain: "lockin-8c95f.firebaseapp.com",
      projectId: "lockin-8c95f",
      storageBucket: "lockin-8c95f.appspot.com",
      messagingSenderId: "717488583871",
      appId: "1:717488583871:web:318cf76e0c8c45f0aaa336",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final baseText = GoogleFonts.interTextTheme(Theme.of(context).textTheme)
        .copyWith(
          displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        );

    return MaterialApp(
      title: 'LockIn — Focus & Productivity',
      debugShowCheckedModeBanner: false,
      theme: buildLockInDarkTheme(baseText),
      initialRoute: '/',
      routes: {
        '/': (_) => const WelcomeScreen(),
        '/auth': (_) => const AuthScreen(),
        '/user-type': (_) => const UserTypeSelectionScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/focus': (_) => const FocusLockScreen(),
        '/group': (_) => const GroupLockScreen(),
        '/achievements': (_) => const AchievementsScreen(),
        '/calendar': (_) => const CalendarScreen(),
        '/leaderboard': (_) => const LeaderboardScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/task-create': (_) => const TaskCreateScreen(),
        '/parental': (_) => const ParentDashboardScreen(),
        '/join-child': (_) => const JoinChildScreen(),
        '/parent-dashboard': (_) => const ParentDashboardScreen(),
        '/child-management': (_) => const ChildManagementScreen(),
        '/reports': (_) => const ReportsScreen(),
      },
    );
  }
}

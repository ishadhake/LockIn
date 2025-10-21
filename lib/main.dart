import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'screens.dart';
import 'screens/group_creation_screen.dart';
import 'screens/group_join_screen.dart';
import 'services/group_service.dart';
import 'services/realtime_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize group service with a temporary user ID
  // In a real app, this would come from authentication
  GroupService().initialize('user_${DateTime.now().millisecondsSinceEpoch}');
  
  // Start real-time updates
  RealtimeService().startRealtimeUpdates();
  
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
        '/group-create': (_) => const GroupCreationScreen(),
        '/group-join': (_) => const GroupJoinScreen(),
      },
    );
  }
}

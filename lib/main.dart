import 'package:flutter/material.dart';
import 'package:finallanggo/screens/onboarding_screen.dart';
import 'package:finallanggo/screens/login_screen.dart';
import 'package:finallanggo/screens/home_screen.dart';
import 'package:finallanggo/screens/profile_screen.dart';
import 'package:finallanggo/screens/lesson_screen.dart';
import 'package:finallanggo/screens/lesson_complete_screen.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finallanggo/models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isFirstVisit = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkFirstVisit();
    _checkLoginStatus();
  }

  Future<void> _checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
    
    setState(() {
      isFirstVisit = !hasCompletedOnboarding;
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');
    final userAge = prefs.getInt('userAge');
    final userAvatar = prefs.getString('userAvatar');

    if (userName != null && userAge != null) {
      setState(() {
        isLoggedIn = true;
        currentUser = User(
          name: userName,
          avatar: userAvatar ?? 'https://api.dicebear.com/7.x/avataaars/svg?seed=John',
          xp: 0,
          wordsLearned: 0,
          totalLearningDays: 0,
          achievementsEarned: 0,
          totalAchievements: 0,
          dailyXp: 0,
          dailyGoal: 100,
          streak: 0,
          level: 1,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LangGo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      initialRoute: isFirstVisit ? '/login' : (isLoggedIn ? '/home' : '/login'),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/lesson': (context) => const LessonScreen(),
        '/lesson-complete': (context) => const LessonCompleteScreen(
          correctAnswers: 0, // Placeholder, will be replaced with actual values
          incorrectAnswersCount: 0, // Placeholder, will be replaced with actual values
          totalQuestions: 0, // Placeholder, will be replaced with actual values
          timeTaken: 0, // Placeholder, will be replaced with actual values
        ),
      },
    );
  }
}

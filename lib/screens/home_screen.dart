import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finallanggo/widgets/mascot.dart';
import 'package:finallanggo/widgets/language_selector.dart';
import 'package:finallanggo/widgets/user_progress.dart';
import 'package:finallanggo/widgets/lesson_card.dart';
import 'package:finallanggo/models/lesson.dart';
import 'package:finallanggo/models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedLanguage = "tagalog";
  String _userName = "User";

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/drawer_bg.png'),
            fit: BoxFit.cover, // Ensures the background fills the entire screen
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: currentUser.avatar.isNotEmpty
                        ? NetworkImage(currentUser.avatar)
                        : const AssetImage('assets/images/whiteboy.png') as ImageProvider,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, "Home", () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(Icons.person, "Profile", () {
              Navigator.pushNamed(context, '/profile');
            }),
            _buildDrawerItem(Icons.logout, "Logout", () {
              Navigator.pushReplacementNamed(context, '/login');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
      _selectedLanguage = prefs.getString('selectedLanguage') ?? "tagalog";
    });
  }

  Future<void> _handleLanguageSelect(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  void _handleSelectLesson(String lessonId) {
    Navigator.pushNamed(context, '/lesson', arguments: lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 36, height: 36),
            const SizedBox(width: 8),
            const Text(
              'Learn Filipino',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 2,
        backgroundColor: Colors.blueAccent,
      ),
      drawer: _buildDrawer(context),
      body: Container(
        width: double.infinity,
        height: double.infinity, // Ensures full-screen coverage
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/drawer_bg.png'),
            fit: BoxFit.cover, // Ensures background fills the screen
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              UserProgress(user: currentUser),
              const SizedBox(height: 24),
              Mascot(
                message: "Let's continue learning ${_selectedLanguage.toUpperCase()} today!",
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Learning Path',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Ensure text is readable
                ),
              ),
              const SizedBox(height: 24),
              _buildLessonGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: currentUser.avatar.isNotEmpty
              ? NetworkImage(currentUser.avatar)
              : const AssetImage('assets/images/whiteboy.png') as ImageProvider,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kamusta, $_userName!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Improve readability
                ),
              ),
              const Text(
                'Select a language and start learning',
                style: TextStyle(color: Colors.white70), // Light color for readability
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 150,
          child: LanguageSelector(
            onSelect: _handleLanguageSelect,
            defaultLanguage: _selectedLanguage,
          ),
        ),
      ],
    );
  }

  Widget _buildLessonGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: sampleLessons.length,
      itemBuilder: (context, index) {
        final lesson = sampleLessons[index];
        return LessonCard(
          lesson: lesson,
          onTap: () {
            _handleSelectLesson(lesson.id);
          },
        );
      },
    );
  }
}

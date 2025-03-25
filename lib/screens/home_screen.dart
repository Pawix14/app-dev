import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
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
  List<Lesson> _lessons = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLessons();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
      _selectedLanguage = prefs.getString('selectedLanguage') ?? "tagalog";
    });
  }

  Future<void> _loadLessons() async {
    if (!_isRefreshing) {
      setState(() {
        _isLoading = true;
      });
    }
    
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _lessons = sampleLessons;
      _isLoading = false;
      _isRefreshing = false;
    });
  }

  Future<void> _handleLanguageSelect(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  // Ensure the lesson ID is correctly passed when navigating to the lesson screen
  void _handleSelectLesson(String lessonId) {
    Navigator.pushNamed(context, '/lesson', arguments: lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Image.asset('assets/images/logo.png', width: 36, height: 36),
          const SizedBox(width: 8),
          const Text(
            'Learn Filipino',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      elevation: 2,
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/drawer_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isRefreshing = true;
          });
          await _loadLessons();
          return Future.value();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              UserProgress(user: currentUser),
              const SizedBox(height: 24),
              Mascot(
                message:
                    "Let's continue learning ${_selectedLanguage.toUpperCase()} today!",
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(),
              const SizedBox(height: 16),
              _buildLessonGrid(),
              // Ensure there's enough space at the bottom for comfortable scrolling
              const SizedBox(height: 40),
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
                  color: Colors.white,
                ),
              ),
              const Text(
                'Select a language and start learning',
                style: TextStyle(
                  color: Colors.white70,
                ),
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

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Learning Path',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (_isLoading && !_isRefreshing)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          ),
      ],
    );
  }

  Widget _buildLessonGrid() {
    if (_isLoading && !_isRefreshing) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading lessons...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_lessons.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
              const SizedBox(height: 16),
              Text(
                'No lessons available for $_selectedLanguage yet',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadLessons,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: _lessons.length,
          itemBuilder: (context, index) {
            final lesson = _lessons[index];
            return Hero(
              tag: 'lesson_${lesson.id}',
              child: LessonCard(
                lesson: lesson,
                onTap: () {
                  _handleSelectLesson(lesson.id);
                },
              ),
            );
          },
        );
      }
    );
  }
}

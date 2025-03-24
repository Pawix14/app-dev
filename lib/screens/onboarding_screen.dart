import 'package:flutter/material.dart';
import 'package:finallanggo/widgets/mascot.dart';
import 'package:finallanggo/widgets/language_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedLanguage = "tagalog";
  String _dailyGoal = "medium";
  final FlutterTts flutterTts = FlutterTts();

  final List<Map<String, String>> _steps = [
    {
      "id": "welcome",
      "title": "Welcome to LangGo!",
      "description":
          "Learn Philippine Native languages in a fun and interactive way.",
    },
    {
      "id": "language",
      "title": "Choose Your Language",
      "description": "Select the Philippine language you want to learn.",
    },
    {
      "id": "goals",
      "title": "Set Your Daily Goals",
      "description": "How much time would you like to spend learning each day?",
    },
    {
      "id": "complete",
      "title": "You're All Set!",
      "description": "Your learning journey is about to begin.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    flutterTts.stop();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? "tagalog";
      _dailyGoal = prefs.getString('dailyGoal') ?? "medium";
    });
  }

  void _handleNext() async {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);
      await prefs.setString('selectedLanguage', _selectedLanguage);
      await prefs.setString('dailyGoal', _dailyGoal);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _handleBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleLanguageSelect(String language) {
    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // Ensure full coverage
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/drawer_bg.png'),
            fit: BoxFit.cover, // Ensure the background fills the screen
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _steps[_currentPage]["title"]!,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            _steps[_currentPage]["description"]!,
                            style: const TextStyle(
                              fontSize: 16,
                              color:
                                  Colors.white70, // Light color for readability
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.white),
                      onPressed: () =>
                          _speak(_steps[_currentPage]["description"]!),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: (_currentPage + 1) / _steps.length,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildWelcomeStep(),
                      _buildLanguageStep(),
                      _buildGoalsStep(),
                      _buildCompleteStep(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentPage == 0 ? null : _handleBack,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Better visibility
                        foregroundColor: Colors.blueAccent,
                      ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blueAccent,
                      ),
                      icon: _currentPage < _steps.length - 1
                          ? const Icon(Icons.arrow_forward)
                          : const Icon(Icons.check),
                      label: Text(
                        _currentPage < _steps.length - 1
                            ? 'Continue'
                            : 'Start Learning',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Mascot(
          message:
              "Mabuhay! Welcome to your Filipino Native language learning journey!",
        ),
        SizedBox(height: 24),
        Text(
          'Get ready to learn Philippine Native languages through fun, interactive lessons and games! Earn XP, complete quests, and track your progress as you learn!',
          style: TextStyle(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLanguageStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Choose which Philippine language you'd like to learn",
          style: TextStyle(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 250,
          child: LanguageSelector(
            onSelect: _handleLanguageSelect,
            defaultLanguage: _selectedLanguage,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsStep() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "How much time would you like to dedicate to learning each day?",
          style: TextStyle(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompleteStep() {
    return const Center(
      child: Mascot(
        message: "Congratulations! You're all set to start learning!",
      ),
    );
  }
}

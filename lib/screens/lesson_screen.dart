import 'package:flutter/material.dart';
import 'package:finallanggo/models/exercise.dart';
import 'package:finallanggo/models/lesson.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LessonScreen extends StatefulWidget {
  final String? lessonId;

  const LessonScreen({super.key, this.lessonId});

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  int currentExerciseIndex = 0;
  String? selectedAnswer;
  bool isAnswerChecked = false;
  int correctAnswers = 0;
  List<String> incorrectAnswers = [];
  DateTime? lessonStartTime;
  bool isLoading = true;

  final FlutterTts flutterTts = FlutterTts();
  late List<Exercise> filteredExercises = [];
  late AnimationController _fadeController;
  late Lesson currentLesson;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    lessonStartTime = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLessonAndExercises();
  }

  Future<void> _loadLessonAndExercises() async {
    setState(() {
      isLoading = true;
    });

    // Get lessonId from widget or route arguments
    final lessonId = widget.lessonId ?? ModalRoute.of(context)?.settings.arguments as String?;
    print("Loading lesson with ID: $lessonId"); // Debug statement to log lessonId

    if (lessonId != null) {
      // Simulate network delay for fetching data
      await Future.delayed(const Duration(milliseconds: 800));

      final lesson = sampleLessons.firstWhere(
        (lesson) => lesson.id == lessonId,
        orElse: () => Lesson(
          id: "0",
          title: "Unknown",
          description: "",
          progress: 0,
          stars: 0,
          maxStars: 3,
          locked: false,
          dialect: "Unknown",
        ),
      );

      currentLesson = lesson;

      final exercises = sampleExercises.where((exercise) {
      print("Filtering exercises for lesson ID: ${lesson.id} and dialect: ${lesson.dialect}"); // Debug statement to log filtering
        return exercise.lessonId == lesson.id &&
            exercise.dialect.toLowerCase() == lesson.dialect.toLowerCase();
      }).toList();

      setState(() {
        filteredExercises = exercises;
        isLoading = false;
        _fadeController.forward();
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Exercise get currentExercise => filteredExercises.isNotEmpty
      ? filteredExercises[currentExerciseIndex]
      : Exercise(
          id: "0",
          lessonId: "0",
          category: "none",
          type: ExerciseType.multipleChoice,
          question: "No exercises available",
          options: [],
          correctAnswer: "",
          dialect: "",
        );

  double get progress => (filteredExercises.isEmpty)
      ? 0
      : (currentExerciseIndex + 1) / filteredExercises.length * 100;

  bool get isCorrect => selectedAnswer == currentExercise.correctAnswer;

  @override
  void dispose() {
    flutterTts.stop();
    _fadeController.dispose();
    super.dispose();
  }

  void handleSelectAnswer(String answer) {
    if (isAnswerChecked) return;
    setState(() {
      selectedAnswer = answer;
    });
  }

  void handleCheckAnswer() {
    if (selectedAnswer == null) return;
    setState(() {
      isAnswerChecked = true;
      if (selectedAnswer == currentExercise.correctAnswer) {
        correctAnswers++;
      } else {
        incorrectAnswers.add(currentExercise.question);
      }
    });
  }

  void handleNextExercise() {
    if (currentExerciseIndex < filteredExercises.length - 1) {
      setState(() {
        _fadeController.forward(from: 0);
        currentExerciseIndex++;
        selectedAnswer = null;
        isAnswerChecked = false;
      });
    } else {
      final lessonEndTime = DateTime.now();
      final timeTaken = lessonEndTime.difference(lessonStartTime!).inSeconds;
      Navigator.pushReplacementNamed(context, '/lesson-complete', arguments: {
        'incorrectAnswers': incorrectAnswers.length,
        'correctAnswers': correctAnswers,
        'totalQuestions': filteredExercises.length,
        'timeTaken': timeTaken,
        'incorrectAnswersCount': incorrectAnswers.length,
      });
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    try {
      String languageCode = "en-US";
      if (currentExercise.dialect.toLowerCase() == "tagalog") {
        languageCode = "fil-PH";
      } else if (currentExercise.dialect.toLowerCase() == "cebuano") {
        languageCode = "ceb-PH";
      }

      await flutterTts.setLanguage(languageCode);
      await flutterTts.setPitch(1.0);
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.speak(text);
    } catch (e) {
      debugPrint("Error in TTS: $e");
    }
  }

  Color getOptionColor(String option) {
    if (!isAnswerChecked) {
      return selectedAnswer == option ? Colors.blue.shade300 : Colors.white;
    } else {
      if (option == currentExercise.correctAnswer) {
        return Colors.green.shade100;
      } else if (selectedAnswer == option &&
          selectedAnswer != currentExercise.correctAnswer) {
        return Colors.red.shade100;
      } else {
        return Colors.white;
      }
    }
  }

  Color getOptionBorderColor(String option) {
    if (!isAnswerChecked) {
      return selectedAnswer == option
          ? Colors.blue.shade400
          : Colors.grey.shade300;
    } else {
      if (option == currentExercise.correctAnswer) {
        return Colors.green;
      } else if (selectedAnswer == option &&
          selectedAnswer != currentExercise.correctAnswer) {
        return Colors.red;
      } else {
        return Colors.grey.shade300;
      }
    }
  }

  Widget? getOptionIcon(String option) {
    if (!isAnswerChecked) {
      return selectedAnswer == option
          ? const Icon(Icons.check_circle_outline, color: Colors.blue, size: 20)
          : null;
    } else {
      if (option == currentExercise.correctAnswer) {
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      } else if (selectedAnswer == option &&
          selectedAnswer != currentExercise.correctAnswer) {
        return const Icon(Icons.cancel, color: Colors.red, size: 20);
      } else {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Lesson'),
          backgroundColor: Colors.blue.shade900,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (filteredExercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: const Center(
            child: Text('No exercises available for this lesson.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(currentLesson.title),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/drawer_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLessonHeader(currentLesson),
                const SizedBox(height: 20),
                _buildLessonDescription(currentLesson),
                const SizedBox(height: 20),
                _buildQuestionCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonHeader(Lesson lesson) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade900.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            lesson.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '${currentExerciseIndex + 1}/${filteredExercises.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (currentExerciseIndex + 1 == filteredExercises.length)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Achievement Unlocked!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.blue.shade200.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade300),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLessonDescription(Lesson lesson) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Text(
          lesson.description,
          style: const TextStyle(
            fontSize: 20,
            height: 1.6,
            color: Colors.black87,
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return FadeTransition(
      opacity: _fadeController,
      child: Card(
        color: Colors.blue.shade800,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuestionText(),
              const SizedBox(height: 24),
              _buildAnswerOptions(),
              if (isAnswerChecked) _buildAnswerFeedback(),
              _buildNextOrCheckButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              currentExercise.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.white),
              onPressed: () => speak(currentExercise.question),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions() {
    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          children: currentExercise.options
              .map((option) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: double.infinity,
                    child: Material(
                      color: getOptionColor(option),
                      borderRadius: BorderRadius.circular(12),
                      elevation: selectedAnswer == option ? 2 : 0,
                      child: InkWell(
                        onTap: isAnswerChecked ? null : () => handleSelectAnswer(option),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: getOptionBorderColor(option),
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: selectedAnswer == option ? FontWeight.bold : FontWeight.normal,
                                    color: selectedAnswer == option ? Colors.blue.shade900 : Colors.blue.shade900,
                                  ),
                                ),
                              ),
                              if (getOptionIcon(option) != null) getOptionIcon(option)!,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildAnswerFeedback() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isCorrect ? "Correct! Well done!" : "Incorrect. The correct answer is: ${currentExercise.correctAnswer}",
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextOrCheckButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isAnswerChecked ? Colors.green.shade600 : Colors.blue.shade500,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: selectedAnswer == null ? null : (isAnswerChecked ? handleNextExercise : handleCheckAnswer),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isAnswerChecked ? 'Continue' : 'Check Answer',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isAnswerChecked ? Icons.arrow_forward : Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }
}

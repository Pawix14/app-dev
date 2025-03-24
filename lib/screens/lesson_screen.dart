import 'package:flutter/material.dart';
import 'package:finallanggo/models/exercise.dart';
import 'package:finallanggo/models/lesson.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  int currentExerciseIndex = 0;
  String? selectedAnswer;
  bool isAnswerChecked = false;
  int correctAnswers = 0;
  final FlutterTts flutterTts = FlutterTts();
  late List<Exercise> filteredExercises = [];
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterExercises();
  }

  void _filterExercises() {
    final lessonId = ModalRoute.of(context)?.settings.arguments as String?;
    if (lessonId != null) {
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

      debugPrint("Lesson ID: $lessonId");
      debugPrint("Lesson dialect: ${lesson.dialect}");

      setState(() {
        // ✅ Fixed Filtering Logic
        filteredExercises = sampleExercises.where((exercise) {
          debugPrint("Exercise - lessonId: ${exercise.lessonId}, dialect: ${exercise.dialect}");
          return exercise.lessonId == lesson.id &&
              exercise.dialect.toLowerCase() == lesson.dialect.toLowerCase();
        }).toList();

        _fadeController.forward(); // ✅ Start the fade animation
      });

      debugPrint("Filtered ${filteredExercises.length} exercises for dialect: ${lesson.dialect}");
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
      Navigator.pushReplacementNamed(context, '/lesson-complete');
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

  @override
  Widget build(BuildContext context) {
    final lessonId = ModalRoute.of(context)?.settings.arguments as String?;
    if (lessonId == null || filteredExercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: const Center(
            child: Text('No lesson selected or no exercises available.')),
      );
    }

    final lesson = sampleLessons.firstWhere((lesson) => lesson.id == lessonId);

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/drawer_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lesson Title & Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        '${currentExerciseIndex + 1}/${filteredExercises.length}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Animated Question Card
              Expanded(
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question Text & Speak Button
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  currentExercise.question,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up,
                                    color: Colors.blueAccent),
                                onPressed: () =>
                                    speak(currentExercise.question),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Answer Options
                          ...currentExercise.options.map((option) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    backgroundColor: selectedAnswer == option
                                        ? Colors.blueAccent.withOpacity(0.1)
                                        : Colors.white,
                                  ),
                                  onPressed: isAnswerChecked
                                      ? null
                                      : () => handleSelectAnswer(option),
                                  child: Text(option),
                                ),
                              )),

                          const SizedBox(height: 24),

                          // Answer Feedback
                          if (isAnswerChecked)
                            Text(
                              isCorrect
                                  ? "✅ Correct!"
                                  : "❌ Incorrect. The correct answer is: ${currentExercise.correctAnswer}",
                              style: TextStyle(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          // Next / Check Answer Button
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(12)),
                              onPressed: isAnswerChecked
                                  ? handleNextExercise
                                  : handleCheckAnswer,
                              child: Text(
                                  isAnswerChecked ? 'Next' : 'Check Answer'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

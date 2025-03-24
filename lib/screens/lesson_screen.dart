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
          debugPrint(
              "Exercise - lessonId: ${exercise.lessonId}, dialect: ${exercise.dialect}");
          return exercise.lessonId == lesson.id &&
              exercise.dialect.toLowerCase() == lesson.dialect.toLowerCase();
        }).toList();

        _fadeController.forward(); // ✅ Start the fade animation
      });

      debugPrint(
          "Filtered ${filteredExercises.length} exercises for dialect: ${lesson.dialect}");
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

  // Get status color for option based on selection and check status
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

  // Get border color for option based on selection and check status
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

  // Get icon for option based on selection and check status
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
      appBar: AppBar(
        title: Text(lesson.title),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
      ),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${currentExerciseIndex + 1}/${filteredExercises.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              backgroundColor:
                                  Colors.blue.shade200.withOpacity(0.3),
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
              ),
              const SizedBox(height: 20),

              // Animated Question Card
              Expanded(
                child: FadeTransition(
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
                          // Question Text & Speak Button
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
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
                                    icon: const Icon(Icons.volume_up,
                                        color: Colors.white),
                                    onPressed: () =>
                                        speak(currentExercise.question),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Answer Options
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: currentExercise.options
                                    .map((option) => Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          width: double.infinity,
                                          child: Material(
                                            color: getOptionColor(option),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            elevation: selectedAnswer == option
                                                ? 2
                                                : 0,
                                            child: InkWell(
                                              onTap: isAnswerChecked
                                                  ? null
                                                  : () => handleSelectAnswer(
                                                      option),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: getOptionBorderColor(
                                                        option),
                                                    width: 2,
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 14),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        option,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              selectedAnswer ==
                                                                      option
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal,
                                                          color:
                                                              selectedAnswer ==
                                                                      option
                                                                  ? Colors.blue
                                                                      .shade900
                                                                  : Colors.blue
                                                                      .shade900,
                                                        ),
                                                      ),
                                                    ),
                                                    if (getOptionIcon(option) !=
                                                        null)
                                                      getOptionIcon(option)!,
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),

                          // Answer Feedback
                          if (isAnswerChecked)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16, top: 8),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCorrect ? Colors.green : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isCorrect
                                          ? "Correct! Well done!"
                                          : "Incorrect. The correct answer is: ${currentExercise.correctAnswer}",
                                      style: TextStyle(
                                        color: isCorrect
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Next / Check Answer Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isAnswerChecked
                                    ? Colors.green.shade600
                                    : Colors.blue.shade500,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                padding: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: selectedAnswer == null
                                  ? null
                                  : (isAnswerChecked
                                      ? handleNextExercise
                                      : handleCheckAnswer),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isAnswerChecked
                                        ? 'Continue'
                                        : 'Check Answer',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isAnswerChecked
                                        ? Icons.arrow_forward
                                        : Icons.check_circle,
                                  ),
                                ],
                              ),
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

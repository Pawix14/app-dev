import 'package:flutter/material.dart';

class LessonCompleteScreen extends StatelessWidget {
  final int correctAnswers;
  final int incorrectAnswersCount;
  final int totalQuestions;
  final int timeTaken;

  const LessonCompleteScreen({
    super.key,
    required this.correctAnswers,
    required this.incorrectAnswersCount,
    required this.totalQuestions,
    required this.timeTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Completed!'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              "Lesson Completed!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Correct Answers: $correctAnswers",
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            Text(
              "Incorrect Answers: $incorrectAnswersCount",
              style: const TextStyle(fontSize: 20, color: Colors.red),
            ),
            Text(
              "Total Questions: $totalQuestions",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Text(
              "Time Taken: $timeTaken seconds",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/home'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Return to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
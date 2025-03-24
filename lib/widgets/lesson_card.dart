import 'package:flutter/material.dart';
import 'package:finallanggo/models/lesson.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: lesson.locked ? 0.6 : 1.0,
      child: Card(
        color: Colors.white,
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Prevents unnecessary expansion
            children: [
              /// **🔹 Title**
              Text(
                lesson.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              
              const SizedBox(height: 4),
              
              /// **🔹 Description with `Expanded`**
              Flexible(
                child: Text(
                  lesson.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),

              const SizedBox(height: 12),

              /// **🔹 Progress Info**
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    '${lesson.progress.round()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              /// **🔹 Progress Bar**
              LinearProgressIndicator(
                value: lesson.progress / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 8),

              /// **🔹 Star Ratings (Fixed Size)**
              SizedBox(
                height: 24, // Fix height to prevent shifting
                child: Row(
                  children: List.generate(
                    lesson.maxStars,
                    (index) => Icon(
                      Icons.star,
                      color: index < lesson.stars ? Colors.amber : Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// **🔹 Always Visible Button**
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: lesson.locked ? null : onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lesson.locked ? Colors.grey[400] : Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    lesson.locked ? 'Locked' : lesson.progress > 0 ? 'Continue' : 'Start',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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

class Lesson {
  final String id;
  final String title;
  final String description;
  final double progress;
  final int stars;
  final int maxStars;
  final bool locked;
  final String dialect; // Added dialect property

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.stars,
    required this.maxStars,
    required this.locked,
    required this.dialect, // Updated constructor
  });
}

List<Lesson> sampleLessons = [
  // Basic Greetings per dialect
  Lesson(
    id: "basic_tagalog",
    title: "Basic Greetings",
    description: "Learn common greetings in Tagalog.",
    progress: 75,
    stars: 2,
    maxStars: 3,
    locked: false,
    dialect: "Tagalog",
  ),
  Lesson(
    id: "basic_ilonggo",
    title: "Basic Greetings",
    description: "Learn common greetings in Ilonggo.",
    progress: 50,
    stars: 1,
    maxStars: 3,
    locked: false,
    dialect: "Ilonggo",
  ),
  Lesson(
    id: "basic_cebuano",
    title: "Basic Greetings",
    description: "Learn common greetings in Cebuano.",
    progress: 30,
    stars: 1,
    maxStars: 3,
    locked: false,
    dialect: "Cebuano",
  ),

  // Numbers & Counting per dialect
  Lesson(
    id: "numbers_tagalog",
    title: "Numbers & Counting",
    description: "Master numbers in Tagalog.",
    progress: 30,
    stars: 1,
    maxStars: 3,
    locked: false,
    dialect: "Tagalog",
  ),
  Lesson(
    id: "numbers_ilonggo",
    title: "Numbers & Counting",
    description: "Master numbers in Ilonggo.",
    progress: 20,
    stars: 1,
    maxStars: 3,
    locked: false,
    dialect: "Ilonggo",
  ),
  Lesson(
    id: "numbers_cebuano",
    title: "Numbers & Counting",
    description: "Master numbers in Cebuano.",
    progress: 10,
    stars: 0,
    maxStars: 3,
    locked: false,
    dialect: "Cebuano",
  ),

  // Family Members per dialect
  Lesson(
    id: "family_tagalog",
    title: "Family Members",
    description: "Learn family terms in Tagalog.",
    progress: 10,
    stars: 1,
    maxStars: 3,
    locked: false,
    dialect: "Tagalog",
  ),
  Lesson(
    id: "family_ilonggo",
    title: "Family Members",
    description: "Learn family terms in Ilonggo.",
    progress: 5,
    stars: 1,
    maxStars: 3,
    locked: false,
    dialect: "Ilonggo",
  ),
  Lesson(
    id: "family_cebuano",
    title: "Family Members",
    description: "Learn family terms in Cebuano.",
    progress: 0,
    stars: 0,
    maxStars: 3,
    locked: false,
    dialect: "Cebuano",
  ),

  // Common Phrases per dialect
  Lesson(
    id: "phrases_tagalog",
    title: "Common Phrases",
    description: "Essential phrases in Tagalog.",
    progress: 50,
    stars: 2,
    maxStars: 3,
    locked: false,
    dialect: "Tagalog",
  ),
  Lesson(
    id: "phrases_ilonggo",
    title: "Common Phrases",
    description: "Essential phrases in Ilonggo.",
    progress: 15,
    stars: 1,
    maxStars: 3,
    locked: false,
    dialect: "Ilonggo",
  ),
  Lesson(
    id: "phrases_cebuano",
    title: "Common Phrases",
    description: "Essential phrases in Cebuano.",
    progress: 25,
    stars: 1,
    maxStars: 3,
    locked: false,
    dialect: "Cebuano",
  ),
];

class User {
  String name;
  String avatar;
  int xp;
  int wordsLearned;
  int totalLearningDays;
  int achievementsEarned;
  int totalAchievements;
  int dailyXp; // Add this property
  int dailyGoal; // Add this property
  int streak; // Add this property
  int level; // Add this property

  User({
    required this.name,
    required this.avatar,
    required this.xp,
    required this.wordsLearned,
    required this.totalLearningDays,
    required this.achievementsEarned,
    required this.totalAchievements,
    required this.dailyXp, // Initialize this property
    required this.dailyGoal, // Initialize this property
    required this.streak, // Initialize this property
    required this.level, // Initialize this property
  });
}

User currentUser = User(
  name: 'John Doe',
  avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=John',
  xp: 500,
  wordsLearned: 78,
  totalLearningDays: 30,
  achievementsEarned: 5,
  totalAchievements: 10,
  dailyXp: 50, // Example value
  dailyGoal: 100, // Example value
  streak: 7, // Example value
  level: 5, // Example value
);
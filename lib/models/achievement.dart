class Achievement {
  final String name;
  final String description;
  final String iconName;
  final bool earned;
  final String? date;

  Achievement({
    required this.name,
    required this.description,
    required this.iconName,
    required this.earned,
    this.date,
  });
}

List<Achievement> achievements = [
  Achievement(
    name: 'First Steps',
    description: 'Complete your first lesson',
    iconName: 'star',
    earned: true,
    date: '2025-03-01',
  ),
  Achievement(
    name: 'Consistency',
    description: 'Learn for 7 days in a row',
    iconName: 'flame',
    earned: false,
  ),
  // Add more achievements as needed
];
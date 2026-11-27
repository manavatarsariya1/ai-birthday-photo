class CreationItemModel {
  final String id;
  final String path;
  final String type; // 'photo', 'video', 'card'
  final DateTime createdAt;

  const CreationItemModel({
    required this.id,
    required this.path,
    required this.type,
    required this.createdAt,
  });

  String get sectionLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDay = DateTime(createdAt.year, createdAt.month, createdAt.day);
    if (itemDay == today) return 'TODAY';
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]}';
  }
}

class StudentProfile {
  final String name;
  final String examType;
  final DateTime targetExamDate;
  final double dailyStudyHours;
  final String currentStressLevel; // 'Low', 'Moderate', 'High'

  const StudentProfile({
    required this.name,
    required this.examType,
    required this.targetExamDate,
    required this.dailyStudyHours,
    required this.currentStressLevel,
  });

  StudentProfile copyWith({
    String? name,
    String? examType,
    DateTime? targetExamDate,
    double? dailyStudyHours,
    String? currentStressLevel,
  }) {
    return StudentProfile(
      name: name ?? this.name,
      examType: examType ?? this.examType,
      targetExamDate: targetExamDate ?? this.targetExamDate,
      dailyStudyHours: dailyStudyHours ?? this.dailyStudyHours,
      currentStressLevel: currentStressLevel ?? this.currentStressLevel,
    );
  }

  // Helper to calculate days remaining
  int get daysRemaining {
    final now = DateTime.now();
    final difference = targetExamDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    return difference < 0 ? 0 : difference;
  }
}

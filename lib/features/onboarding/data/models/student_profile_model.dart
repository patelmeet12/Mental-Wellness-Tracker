import '../../domain/entities/student_profile.dart';

class StudentProfileModel extends StudentProfile {
  const StudentProfileModel({
    required super.name,
    required super.examType,
    required super.targetExamDate,
    required super.dailyStudyHours,
    required super.currentStressLevel,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      name: json['name'] as String? ?? '',
      examType: json['examType'] as String? ?? 'NEET',
      targetExamDate: DateTime.parse(json['targetExamDate'] as String? ?? DateTime.now().toIso8601String()),
      dailyStudyHours: (json['dailyStudyHours'] as num? ?? 8.0).toDouble(),
      currentStressLevel: json['currentStressLevel'] as String? ?? 'Moderate',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'examType': examType,
      'targetExamDate': targetExamDate.toIso8601String(),
      'dailyStudyHours': dailyStudyHours,
      'currentStressLevel': currentStressLevel,
    };
  }

  factory StudentProfileModel.fromEntity(StudentProfile entity) {
    return StudentProfileModel(
      name: entity.name,
      examType: entity.examType,
      targetExamDate: entity.targetExamDate,
      dailyStudyHours: entity.dailyStudyHours,
      currentStressLevel: entity.currentStressLevel,
    );
  }
}

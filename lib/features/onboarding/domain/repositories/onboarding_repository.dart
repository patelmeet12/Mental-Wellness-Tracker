import '../entities/student_profile.dart';

abstract class OnboardingRepository {
  Future<StudentProfile?> getProfile();
  Future<void> saveProfile(StudentProfile profile);
  Future<void> clearProfile();
}

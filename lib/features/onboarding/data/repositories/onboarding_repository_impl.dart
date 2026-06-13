import '../../domain/entities/student_profile.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../models/student_profile_model.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/errors/failures.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final StorageService _storageService;

  OnboardingRepositoryImpl(this._storageService);

  @override
  Future<StudentProfile?> getProfile() async {
    try {
      final json = _storageService.getProfile();
      if (json == null) return null;
      return StudentProfileModel.fromJson(json);
    } catch (e) {
      throw CacheFailure('Failed to load student profile: $e');
    }
  }

  @override
  Future<void> saveProfile(StudentProfile profile) async {
    try {
      final model = StudentProfileModel.fromEntity(profile);
      await _storageService.saveProfile(model.toJson());
    } catch (e) {
      throw CacheFailure('Failed to save student profile: $e');
    }
  }

  @override
  Future<void> clearProfile() async {
    try {
      await _storageService.clearAll();
    } catch (e) {
      throw CacheFailure('Failed to clear profile cache: $e');
    }
  }
}

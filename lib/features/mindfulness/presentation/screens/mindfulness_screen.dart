import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_wellness_tracker/core/theme/app_colors.dart';
import 'package:mental_wellness_tracker/core/theme/app_spacing.dart';
import 'package:mental_wellness_tracker/core/widgets/glass_card.dart';
import 'package:mental_wellness_tracker/core/widgets/custom_button.dart';
import 'package:mental_wellness_tracker/core/localization/app_localizations.dart';
import 'package:mental_wellness_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:mental_wellness_tracker/features/mindfulness/presentation/providers/mindfulness_provider.dart';
import 'package:mental_wellness_tracker/features/mindfulness/domain/entities/mindfulness_exercise.dart';

class MindfulnessScreen extends ConsumerStatefulWidget {
  const MindfulnessScreen({super.key});

  @override
  ConsumerState<MindfulnessScreen> createState() => _MindfulnessScreenState();
}

class _MindfulnessScreenState extends ConsumerState<MindfulnessScreen> with TickerProviderStateMixin {
  MindfulnessExercise? _activeExercise;
  bool _isGeneratingCustom = false;
  String _customTypeSelected = 'Deep Breathing';

  // Timer fields
  Timer? _timer;
  int _secondsRemaining = 0;
  int _currentStepIndex = 0;
  bool _isTimerRunning = false;
  bool _exerciseCompleted = false;

  // Breathing animation controller
  late AnimationController _breathingController;
  late Animation<double> _pulseAnimation;
  String _breathingActionText = 'Inhale...';

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _breathingController.addStatusListener((status) {
      if (!_isTimerRunning) return;
      if (status == AnimationStatus.completed) {
        setState(() {
          _breathingActionText = 'Hold...';
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (!mounted || !_isTimerRunning) return;
          setState(() {
            _breathingActionText = 'Exhale...';
          });
          _breathingController.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _breathingActionText = 'Hold...';
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (!mounted || !_isTimerRunning) return;
          setState(() {
            _breathingActionText = 'Inhale...';
          });
          _breathingController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    super.dispose();
  }

  // Generate customized mindfulness exercise using Gemini
  Future<void> _generateCustom(AppLocalizations local) async {
    final profile = ref.read(onboardingProvider).valueOrNull;
    if (profile == null) return;

    setState(() {
      _isGeneratingCustom = true;
    });

    try {
      final custom = await ref.read(mindfulnessProvider.notifier).generateCustom(
            type: _customTypeSelected,
            studentProfile: {
              'examType': profile.examType,
              'dailyStudyHours': profile.dailyStudyHours,
              'currentStressLevel': profile.currentStressLevel,
            },
          );
      
      setState(() {
        _activeExercise = custom;
      });
      _startSession(custom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.overwhelmed,
            content: Text('Failed to generate AI exercise: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingCustom = false;
        });
      }
    }
  }

  // Start selected meditation session
  void _startSession(MindfulnessExercise exercise) {
    _timer?.cancel();
    setState(() {
      _activeExercise = exercise;
      _secondsRemaining = exercise.durationSeconds;
      _currentStepIndex = 0;
      _isTimerRunning = true;
      _exerciseCompleted = false;
      _breathingActionText = 'Inhale...';
    });
    
    _breathingController.repeat(reverse: true);
    _runTimer();
  }

  void _runTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
          
          // Switch instructions based on duration division or step count
          final steps = _activeExercise!.steps;
          final stepDuration = _activeExercise!.durationSeconds / steps.length;
          final elapsed = _activeExercise!.durationSeconds - _secondsRemaining;
          final calculatedIndex = (elapsed / stepDuration).floor().clamp(0, steps.length - 1);
          
          if (calculatedIndex != _currentStepIndex) {
            _currentStepIndex = calculatedIndex;
          }
        });
      } else {
        _timer?.cancel();
        _breathingController.stop();
        setState(() {
          _isTimerRunning = false;
          _exerciseCompleted = true;
        });
      }
    });
  }

  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });

    if (_isTimerRunning) {
      _breathingController.repeat(reverse: true);
      _runTimer();
    } else {
      _timer?.cancel();
      _breathingController.stop();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _breathingController.stop();
    setState(() {
      _secondsRemaining = _activeExercise!.durationSeconds;
      _currentStepIndex = 0;
      _isTimerRunning = false;
      _exerciseCompleted = false;
      _breathingActionText = 'Inhale...';
    });
  }

  void _closeSession() {
    _timer?.cancel();
    _breathingController.stop();
    setState(() {
      _activeExercise = null;
      _isTimerRunning = false;
      _exerciseCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final exercisesAsync = ref.watch(mindfulnessProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    Widget buildExerciseTimerPanel() {
      final exercise = _activeExercise!;
      final totalSeconds = exercise.durationSeconds;
      final progress = totalSeconds > 0 ? (totalSeconds - _secondsRemaining) / totalSeconds : 0.0;
      
      final currentStepText = exercise.steps.isNotEmpty 
          ? exercise.steps[_currentStepIndex] 
          : 'Reflect and breathe.';

      final minStr = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
      final secStr = (_secondsRemaining % 60).toString().padLeft(2, '0');

      return Center(
        child: GlassCard(
          width: 650,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    exercise.title,
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _closeSession,
                  ),
                ],
              ),
              const Divider(height: AppSpacing.lg),

              if (!_exerciseCompleted) ...[
                // Timer
                Text(
                  '$minStr:$secStr',
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 48,
                    color: AppColors.primary,
                  ),
                ),
                AppSpacing.gapSM,

                // Progress Bar
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  borderRadius: AppRadius.borderXS,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                AppSpacing.gapXL,

                // Animated Pulsing Breathing Guide for Deep Breathing sessions
                if (exercise.type == 'Deep Breathing') ...[
                  Container(
                    height: 180,
                    alignment: Alignment.center,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 100 * _pulseAnimation.value,
                          height: 100 * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.secondary.withOpacity(0.6),
                                AppColors.primary.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.5),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.3),
                                blurRadius: 24 * _pulseAnimation.value,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _breathingActionText,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  AppSpacing.gapXL,
                ],

                // Step Description Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.03),
                    borderRadius: AppRadius.borderMD,
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? AppColors.darkBorder.withOpacity(0.5) 
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step ${_currentStepIndex + 1} of ${exercise.steps.length}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      AppSpacing.gapXS,
                      Text(
                        currentStepText,
                        style: textTheme.bodyLarge?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapXL,

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.replay),
                      onPressed: _resetTimer,
                    ),
                    AppSpacing.gapMD,
                    IconButton(
                      iconSize: 48,
                      color: AppColors.primary,
                      icon: Icon(_isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_filled),
                      onPressed: _toggleTimer,
                    ),
                  ],
                ),
              ] else ...[
                // Success card when completed
                const Icon(
                  Icons.check_circle,
                  color: AppColors.excellent,
                  size: 80,
                ),
                AppSpacing.gapMD,
                Text(
                  local.completedExercise,
                  style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacing.gapSM,
                const Text(
                  'You\'ve successfully completed this exercise. Your mind is now reset, ready to study with focus.',
                  textAlign: TextAlign.center,
                ),
                AppSpacing.gapLG,
                CustomButton(
                  text: 'Finish Session',
                  width: 150,
                  onPressed: _closeSession,
                ),
              ],
            ],
          ),
        ),
      );
    }

    Widget buildMainPane(List<MindfulnessExercise> exercises) {
      final List<String> dropdownOptions = [
        'Deep Breathing',
        'Focus Reset',
        'Gratitude Reflection',
        'Exam Anxiety Relief',
        'Confidence Boost'
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            local.mindfulnessTitle,
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.gapXS,
          Text(
            local.mindfulnessSubtitle,
            style: textTheme.bodyMedium,
          ),
          AppSpacing.gapLG,

          // AI customized generator bar
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.08),
                AppColors.secondary.withOpacity(0.04),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate AI-Customized Exercise',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Create a mindfulness session tailored to your current stress triggers.',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                DropdownButton<String>(
                  value: _customTypeSelected,
                  style: textTheme.bodyLarge,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _customTypeSelected = newValue;
                      });
                    }
                  },
                  items: dropdownOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                AppSpacing.gapMD,
                CustomButton(
                  text: 'Generate',
                  icon: Icons.auto_awesome,
                  isLoading: _isGeneratingCustom,
                  onPressed: () => _generateCustom(local),
                ),
              ],
            ),
          ),
          AppSpacing.gapLG,

          // Grid/List of standard exercises
          Expanded(
            child: GridView.count(
              crossAxisCount: isDesktop ? 2 : 1,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: isDesktop ? 2.2 : 2.0,
              children: exercises.map((ex) {
                return GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ex.title,
                              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: AppRadius.borderXS,
                            ),
                            child: Text(
                              '${ex.durationSeconds ~/ 60}m',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.gapXS,
                      Text(
                        ex.description,
                        style: textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.gapSM,
                      CustomButton(
                        text: local.startExercise,
                        icon: Icons.play_arrow,
                        width: double.infinity,
                        height: 38,
                        onPressed: () => _startSession(ex),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _activeExercise != null
              ? buildExerciseTimerPanel()
              : exercisesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, __) => Center(child: Text('Error: $e')),
                  data: (exercises) => buildMainPane(exercises),
                ),
        ),
      ),
    );
  }
}

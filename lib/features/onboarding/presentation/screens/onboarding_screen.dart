import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedExamType = 'JEE';
  DateTime? _selectedDate;
  double _studyHours = 8.0;
  String _stressLevel = 'Moderate';

  final List<String> _examTypes = ['NEET', 'JEE', 'UPSC', 'GATE', 'CAT', 'CUET', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, AppLocalizations local) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.darkSurface,
              onSurface: AppColors.darkTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit(AppLocalizations local) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.selectDate)),
      );
      return;
    }

    final success = await ref.read(onboardingProvider.notifier).saveProfile(
          name: _nameController.text.trim(),
          examType: _selectedExamType,
          targetExamDate: _selectedDate!,
          dailyStudyHours: _studyHours,
          currentStressLevel: _stressLevel,
        );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          image: DecorationImage(
            image: const AssetImage('assets/images/bg_blur.png'), // Fallback background if asset doesn't exist
            fit: BoxFit.cover,
            onError: (_, __) {},
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: GlassCard(
                width: 500,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.psychology,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        AppSpacing.gapMD,
                        Expanded(
                          child: Text(
                            local.appName,
                            style: textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapMD,
                    Text(
                      local.onboardingTitle,
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    AppSpacing.gapXS,
                    Text(
                      local.onboardingSubtitle,
                      style: textTheme.bodyMedium,
                    ),
                    AppSpacing.gapLG,

                    // Name Input
                    Text(local.labelName, style: textTheme.titleMedium),
                    AppSpacing.gapXS,
                    TextFormField(
                      controller: _nameController,
                      style: textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: local.hintName,
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return local.hintName;
                        }
                        return null;
                      },
                    ),
                    AppSpacing.gapMD,

                    // Row for Exam Type & Target Exam Date
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(local.labelExamType, style: textTheme.titleMedium),
                              AppSpacing.gapXS,
                              DropdownButtonFormField<String>(
                                value: _selectedExamType,
                                items: _examTypes.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type, style: textTheme.bodyLarge),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedExamType = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.gapMD,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(local.labelTargetExamDate, style: textTheme.titleMedium),
                              AppSpacing.gapXS,
                              InkWell(
                                onTap: () => _pickDate(context, local),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: 14.5, // Matches Dropdown height alignment
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkSurface.withOpacity(0.5) : AppColors.lightSurface,
                                    borderRadius: AppRadius.borderMD,
                                    border: Border.all(
                                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 18),
                                      AppSpacing.gapSM,
                                      Expanded(
                                        child: Text(
                                          _selectedDate == null
                                              ? 'Select Date'
                                              : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                                          style: textTheme.bodyLarge,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapMD,

                    // Daily Study Hours Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(local.labelDailyStudyHours, style: textTheme.titleMedium),
                        Text(
                          '${_studyHours.toInt()} hours/day',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _studyHours,
                      min: 1,
                      max: 16,
                      divisions: 15,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _studyHours = val;
                        });
                      },
                    ),
                    AppSpacing.gapMD,

                    // Stress Baseline Selector
                    Text(local.labelCurrentStressLevel, style: textTheme.titleMedium),
                    AppSpacing.gapSM,
                    Row(
                      children: ['Low', 'Moderate', 'High'].map((level) {
                        final isSelected = _stressLevel == level;
                        Color accentColor;
                        if (level == 'Low') {
                          accentColor = AppColors.excellent;
                        } else if (level == 'Moderate') {
                          accentColor = AppColors.stressed;
                        } else {
                          accentColor = AppColors.overwhelmed;
                        }

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _stressLevel = level;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? accentColor.withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: AppRadius.borderMD,
                                  border: Border.all(
                                    color: isSelected ? accentColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    level,
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? accentColor : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    AppSpacing.gapXL,

                    // Submit Button
                    CustomButton(
                      text: local.startJourney,
                      icon: Icons.arrow_forward_rounded,
                      width: double.infinity,
                      onPressed: () => _submit(local),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

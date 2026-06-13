import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(const Locale('en'));
  }

  // General App Config
  String get appName => 'MindMate AI';
  String get welcomeBack => 'Welcome back';
  String get saving => 'Saving...';
  String get success => 'Success';
  String get errorOccurred => 'An error occurred. Please try again.';
  String get confirmationRequired => 'Confirmation Required';
  String get cancel => 'Cancel';
  String get confirm => 'Confirm';
  String get ok => 'OK';
  String get loading => 'Please wait...';
  String get retry => 'Retry';
  String get settings => 'Settings';

  // Onboarding
  String get onboardingTitle => 'Begin Your Wellness Journey';
  String get onboardingSubtitle => 'Let\'s tailor your AI mental wellness companion to your exam prep.';
  String get labelName => 'Name';
  String get hintName => 'Enter your name';
  String get labelExamType => 'Exam Type';
  String get labelTargetExamDate => 'Target Exam Date';
  String get labelDailyStudyHours => 'Daily Study Hours';
  String get labelCurrentStressLevel => 'Current Stress Level';
  String get stressLow => 'Low';
  String get stressModerate => 'Moderate';
  String get stressHigh => 'High';
  String get startJourney => 'Start Journey';
  String get selectDate => 'Select Target Exam Date';

  // Navigation
  String get navDashboard => 'Dashboard';
  String get navJournal => 'Daily Journal';
  String get navAnalytics => 'AI Insights';
  String get navCoach => 'Wellness Coach';
  String get navMindfulness => 'Mindfulness';

  // Dashboard
  String get wellnessScore => 'Wellness Score';
  String get stressScore => 'Stress Score';
  String get focusScore => 'Focus Score';
  String get countdownTitle => 'Exam Countdown';
  String get daysRemaining => 'Days Remaining';
  String get moodSummary => 'Mood Summary';
  String get quickActions => 'Quick Actions';
  String get addJournalEntry => 'Write Journal Entry';
  String get talkToCoach => 'Talk to Wellness Coach';
  String get takeMindfulnessBreak => 'Take a Mindfulness Break';
  String get wellnessReport => 'Wellness Report';
  String get streaksTitle => 'Streaks';
  String get journalStreak => 'Journal Streak';
  String get moodStreak => 'Mood Streak';
  String get days => 'days';
  String get activeStreak => 'Active Streak';
  String get streakBadge => 'Streak Builder';

  // Journal
  String get journalTitle => 'Daily Reflection Journal';
  String get journalSubtitle => 'Write down your study progress, stressors, feelings, and general mood.';
  String get journalHint => 'How was your study session today? What is stressing you? Write freely...';
  String get submitJournal => 'Submit for AI Emotional Analysis';
  String get analyzeBtn => 'Analyze Entry';
  String get emotionalSummary => 'AI Emotional Analysis';
  String get keyInsights => 'Key Insights';
  String get recommendations => 'Wellness Recommendations';
  String get historyTitle => 'Journal History';
  String get entrySavedSuccess => 'Journal entry successfully saved and analyzed!';
  String get analysisError => 'Unable to analyze entry. Please verify your Gemini API key.';
  String get writePlaceholder => 'Begin writing your thoughts here...';
  String get confirmingDeleteJournal => 'Are you sure you want to delete this journal entry? This action is permanent.';

  // Mood Tracker
  String get moodCheckIn => 'How are you feeling right now?';
  String get moodExcellent => 'Excellent';
  String get moodGood => 'Good';
  String get moodNeutral => 'Neutral';
  String get moodStressed => 'Stressed';
  String get moodOverwhelmed => 'Overwhelmed';

  // Stress Trigger Detection
  String get triggersTitle => 'AI Stress Trigger analysis';
  String get triggersSubtitle => 'Identified recurring factors affecting your productivity and peace of mind:';
  String get triggerExamPressure => 'Exam Pressure';
  String get triggerPoorSleep => 'Poor Sleep';
  String get triggerSocialComparison => 'Social Comparison';
  String get triggerFamilyExpectations => 'Family Expectations';
  String get triggerTimeManagement => 'Time Management';
  String get triggerFearOfFailure => 'Fear of Failure';

  // AI Wellness Coach
  String get coachTitle => 'MindMate Wellness Coach';
  String get coachSubtitle => 'Empathetic conversation helper (Non-medical AI assistance)';
  String get coachPlaceholder => 'Ask me about study anxiety, exam pressure, or coping strategies...';
  String get coachWarning => 'Disclaimer: MindMate AI provides emotional support and wellness suggestions. It is NOT a medical diagnostic tool or clinical substitute. If you are experiencing severe distress, please reach out to a professional counselor.';
  String get clearChatHistory => 'Clear Chat History';
  String get confirmingClearChat => 'Are you sure you want to clear your conversation history?';

  // Mindfulness
  String get mindfulnessTitle => 'Mindfulness & Meditation';
  String get mindfulnessSubtitle => 'AI-recommended exercises designed to reset focus, ease anxiety, and restore calm.';
  String get startExercise => 'Start Exercise';
  String get breathingCircleTitle => 'Breathing Cycle';
  String get inhale => 'Inhale...';
  String get hold => 'Hold...';
  String get exhale => 'Exhale...';
  String get gratitudeReflection => 'Gratitude Reflection';
  String get focusReset => 'Focus Reset';
  String get examAnxietyRelief => 'Anxiety Relief';
  String get confidenceBoost => 'Confidence Boost';
  String get completedExercise => 'Exercise Completed! Well done.';
  String get dailyQuoteTitle => 'Daily Motivation Engine';
  String get getMotivationalMsg => 'Get Encouragement';

  // Settings / API config
  String get settingsTitle => 'MindMate settings';
  String get geminiKeyLabel => 'Gemini API Key';
  String get geminiKeyHint => 'AI features need a Gemini API Key to function. Enter key here:';
  String get saveSettingsBtn => 'Save Settings';
  String get settingsSavedSuccess => 'Settings successfully saved!';
}

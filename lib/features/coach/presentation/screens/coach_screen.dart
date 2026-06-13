import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_wellness_tracker/core/theme/app_colors.dart';
import 'package:mental_wellness_tracker/core/theme/app_spacing.dart';
import 'package:mental_wellness_tracker/core/widgets/glass_card.dart';
import 'package:mental_wellness_tracker/core/widgets/custom_button.dart';
import 'package:mental_wellness_tracker/core/widgets/confirmation_dialog.dart';
import 'package:mental_wellness_tracker/core/localization/app_localizations.dart';
import 'package:mental_wellness_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:mental_wellness_tracker/features/coach/presentation/providers/coach_provider.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send(AppLocalizations local) async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final profile = ref.read(onboardingProvider).valueOrNull;
    if (profile == null) return;

    _inputController.clear();
    setState(() {
      _isSending = true;
    });

    // Send Message
    await ref.read(coachProvider.notifier).sendMessage(
      text,
      {
        'examType': profile.examType,
        'dailyStudyHours': profile.dailyStudyHours,
        'currentStressLevel': profile.currentStressLevel,
      },
    );

    setState(() {
      _isSending = false;
    });
    
    // Allow UI to render then scroll down
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<void> _clearChat(AppLocalizations local) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: local.clearChatHistory,
      content: local.confirmingClearChat,
      confirmText: 'Clear',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirmed) {
      await ref.read(coachProvider.notifier).clearChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final chatAsync = ref.watch(coachProvider);

    // Trigger scroll to bottom on new messages
    ref.listen(coachProvider, (previous, next) {
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          local.coachTitle,
                          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          local.coachSubtitle,
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  CustomButton(
                    text: 'Clear Chat',
                    isSecondary: true,
                    height: 36,
                    icon: Icons.delete_sweep_outlined,
                    onPressed: () => _clearChat(local),
                  ),
                ],
              ),
              AppSpacing.gapMD,

              // Safety Disclaimer
              Card(
                color: AppColors.primary.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMD,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      AppSpacing.gapSM,
                      Expanded(
                        child: Text(
                          local.coachWarning,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? AppColors.darkTextPrimary 
                                : AppColors.lightTextPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.gapLG,

              // Chat Message List
              Expanded(
                child: chatAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, __) => Center(child: Text('Error: $e')),
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.forum_outlined, size: 64, color: AppColors.primary),
                            AppSpacing.gapSM,
                            Text('Hello! I\'m your MindMate coach.', style: textTheme.titleLarge),
                            AppSpacing.gapXS,
                            Text(
                              'Tell me how exam preparation is going or if you feel anxious. I\'m here to listen.',
                              style: textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isUser = msg.sender == 'user';
                        
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isUser) ...[
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    radius: 16,
                                    child: const Icon(Icons.psychology, color: AppColors.primary, size: 16),
                                  ),
                                  AppSpacing.gapSM,
                                ],
                                Flexible(
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 600),
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      gradient: isUser ? AppColors.primaryGradient : null,
                                      color: isUser ? null : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface.withOpacity(0.5) : Colors.white),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                                        bottomRight: Radius.circular(isUser ? 0 : 16),
                                      ),
                                      border: isUser 
                                          ? null 
                                          : Border.all(
                                              color: Theme.of(context).brightness == Brightness.dark 
                                                  ? AppColors.darkBorder.withOpacity(0.5) 
                                                  : AppColors.lightBorder,
                                            ),
                                    ),
                                    child: Text(
                                      msg.text,
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: isUser ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                                if (isUser) ...[
                                  AppSpacing.gapSM,
                                  CircleAvatar(
                                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                                    radius: 16,
                                    child: const Icon(Icons.person, color: AppColors.secondary, size: 16),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              AppSpacing.gapMD,

              // Send Input Row
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: TextField(
                        controller: _inputController,
                        style: textTheme.bodyLarge,
                        onSubmitted: (_) => _send(local),
                        decoration: InputDecoration(
                          hintText: local.coachPlaceholder,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.all(AppSpacing.md),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapSM,
                  CustomButton(
                    text: 'Send',
                    width: 100,
                    isLoading: _isSending,
                    onPressed: () => _send(local),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

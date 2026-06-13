import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/core_providers.dart';
import '../theme/app_spacing.dart';
import '../localization/app_localizations.dart';
import 'custom_button.dart';
import 'glass_card.dart';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  final _keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    _keyController.text = storage.getGeminiApiKey();
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations local) async {
    if (!_formKey.currentState!.validate()) return;
    
    final storage = ref.read(storageServiceProvider);
    await storage.saveGeminiApiKey(_keyController.text.trim());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.settingsSavedSuccess)),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: AppElevations.none,
      child: GlassCard(
        width: 450,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                local.settingsTitle,
                style: textTheme.headlineMedium,
              ),
              AppSpacing.gapSM,
              Text(
                local.geminiKeyHint,
                style: textTheme.bodyMedium,
              ),
              AppSpacing.gapMD,
              TextFormField(
                controller: _keyController,
                style: textTheme.bodyLarge,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: local.geminiKeyLabel,
                  prefixIcon: const Icon(Icons.key, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.info_outline, size: 20),
                    onPressed: () {
                      // Info Dialog or instruction
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('How to get a key?'),
                          content: const Text(
                            '1. Visit Google AI Studio (aistudio.google.com)\n'
                            '2. Sign in with your Google account\n'
                            '3. Click "Create API Key"\n'
                            '4. Copy the generated key and paste it here.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('OK'),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              AppSpacing.gapLG,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: local.cancel,
                    isSecondary: true,
                    height: 38,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  AppSpacing.gapSM,
                  CustomButton(
                    text: local.saveSettingsBtn,
                    height: 38,
                    onPressed: () => _save(local),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

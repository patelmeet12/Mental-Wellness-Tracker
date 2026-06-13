import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../localization/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'confirmation_dialog.dart';
import 'settings_dialog.dart';
import 'glass_card.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  void _onNavigation(BuildContext context, String route) {
    context.go(route);
  }

  Future<void> _resetProfile(BuildContext context, WidgetRef ref, AppLocalizations local) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Reset Companion Data',
      content: 'Are you sure you want to reset all your student profile data, journal logs, and history? This cannot be undone.',
      confirmText: 'Reset Everything',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirmed) {
      await ref.read(onboardingProvider.notifier).clearProfile();
      if (context.mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(onboardingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final local = AppLocalizations.of(context);

    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, __) => Scaffold(body: Center(child: Text('Error loading layout: $e'))),
      data: (profile) {
        if (profile == null) {
          // If no profile, we shouldn't show the layout frame
          return child;
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 768;

        final navItems = [
          _NavItem(local.navDashboard, Icons.dashboard_outlined, Icons.dashboard, '/dashboard'),
          _NavItem(local.navJournal, Icons.book_outlined, Icons.book, '/journal'),
          _NavItem(local.navAnalytics, Icons.analytics_outlined, Icons.analytics, '/analytics'),
          _NavItem(local.navCoach, Icons.forum_outlined, Icons.forum, '/coach'),
          _NavItem(local.navMindfulness, Icons.spa_outlined, Icons.spa, '/mindfulness'),
        ];

        // Drawer / sidebar navigation items widget
        Widget buildNavList(bool inSidebar) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: navItems.map((item) {
              final isSelected = currentRoute == item.route;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs, horizontal: AppSpacing.xs),
                child: InkWell(
                  onTap: () {
                    if (!inSidebar && isMobile) {
                      Navigator.of(context).pop(); // close drawer
                    }
                    _onNavigation(context, item.route);
                  },
                  borderRadius: AppRadius.borderSM,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: AppRadius.borderSM,
                      border: Border.all(
                        color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          size: 20,
                        ),
                        AppSpacing.gapMD,
                        Text(
                          item.title,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }

        // Left sidebar desktop
        Widget buildSidebar() {
          return Container(
            width: 260,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface.withOpacity(0.4) : AppColors.lightSurface,
              border: Border(
                right: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Column(
              children: [
                // Header Logo
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: AppRadius.borderSM,
                        ),
                        child: const Icon(Icons.psychology, color: AppColors.primary, size: 24),
                      ),
                      AppSpacing.gapSM,
                      Expanded(
                        child: Text(
                          local.appName,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Student Profile Quick Info
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.secondary.withOpacity(0.2),
                          child: Text(
                            profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'S',
                            style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        AppSpacing.gapSM,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${profile.examType} Aspirant',
                                style: textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Navigation list
                Expanded(
                  child: SingleChildScrollView(
                    child: buildNavList(true),
                  ),
                ),
                const Divider(height: 1),

                // Settings, Theme & Reset at bottom
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      // Mode Selector
                      ListTile(
                        dense: true,
                        leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20),
                        title: Text(isDark ? 'Light Mode' : 'Dark Mode', style: textTheme.bodyLarge),
                        onTap: () {
                          ref.read(themeModeProvider.notifier).state =
                              isDark ? ThemeMode.light : ThemeMode.dark;
                        },
                      ),
                      // Settings
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.settings, size: 20),
                        title: Text(local.settings, style: textTheme.bodyLarge),
                        onTap: () => SettingsDialog.show(context),
                      ),
                      // Reset Profile
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.logout, color: AppColors.overwhelmed, size: 20),
                        title: const Text('Reset Profile', style: TextStyle(color: AppColors.overwhelmed)),
                        onTap: () => _resetProfile(context, ref, local),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: isMobile
              ? AppBar(
                  title: Row(
                    children: [
                      const Icon(Icons.psychology, color: AppColors.primary),
                      AppSpacing.gapSM,
                      Text(local.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: () {
                        ref.read(themeModeProvider.notifier).state =
                            isDark ? ThemeMode.light : ThemeMode.dark;
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => SettingsDialog.show(context),
                    ),
                  ],
                )
              : null,
          drawer: isMobile
              ? Drawer(
                  child: SafeArea(
                    child: Column(
                      children: [
                        UserAccountsDrawerHeader(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          accountName: Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          accountEmail: Text('${profile.examType} Candidate'),
                          currentAccountPicture: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text(
                              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'S',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(child: buildNavList(false)),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.logout, color: AppColors.overwhelmed),
                          title: const Text('Reset App Data', style: TextStyle(color: AppColors.overwhelmed)),
                          onTap: () => _resetProfile(context, ref, local),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
          body: Row(
            children: [
              if (!isMobile) buildSidebar(),
              Expanded(
                child: Container(
                  color: isDark ? AppColors.darkBg : AppColors.lightBg,
                  child: child,
                ),
              ),
            ],
          ),
          bottomNavigationBar: isMobile
              ? BottomNavigationBar(
                  currentIndex: navItems.indexWhere((item) => currentRoute == item.route).clamp(0, 4),
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  type: BottomNavigationBarType.fixed,
                  onTap: (index) => _onNavigation(context, navItems[index].route),
                  items: navItems.map((item) {
                    return BottomNavigationBarItem(
                      icon: Icon(item.icon),
                      activeIcon: Icon(item.activeIcon),
                      label: item.title,
                    );
                  }).toList(),
                )
              : null,
        );
      },
    );
  }
}

class _NavItem {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  _NavItem(this.title, this.icon, this.activeIcon, this.route);
}

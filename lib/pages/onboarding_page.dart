// lib/pages/onboarding_page.dart

import '../provider/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/design_system.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _completeOnboarding() {
    HapticFeedback.heavyImpact();
    context.read<UserProfileProvider>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final List<Widget> onboardingSteps = [
      _buildOnboardingStep(
        context: context,
        icon: Icons.wallet_rounded,
        title: "Welcome to Tr'Hack!",
        description:
        "Take control of your subscriptions and see where your money is going. Let's start tracking.",
      ),
      _buildOnboardingStep(
        context: context,
        icon: Icons.add_card_rounded,
        title: "Add Subscriptions Easily",
        description:
        "Add subscriptions manually with the '+' button or connect your bank to import them automatically.",
      ),
      _buildOnboardingStep(
        context: context,
        icon: Icons.calendar_month_rounded,
        title: "Visualize Your Spending",
        description:
        "Use the calendar to see upcoming payments at a glance and track your monthly cash flow.",
      ),
      _buildOnboardingStep(
        context: context,
        icon: Icons.insights_rounded,
        title: "Gain Smart Insights",
        description:
        "Set spending limits and add your income to unlock powerful insights about your financial health.",
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingSteps.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return onboardingSteps[index];
                },
              ),
            ),
            _buildNavigationControls(
              context,
              onboardingSteps.length,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingStep({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacing16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.secondary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(icon, size: 64, color: colorScheme.onPrimary),
            ),
          ),
          const SizedBox(height: DesignSystem.spacing16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls(BuildContext context, int totalPages) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLastPage = _currentPage == totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spacing12,
        vertical: DesignSystem.spacing12,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () {
                if (isLastPage) {
                  _completeOnboarding();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                ),
              ),
              child: Text(
                isLastPage ? "Get Started" : "Next",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

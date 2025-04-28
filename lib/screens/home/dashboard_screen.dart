import 'package:diabetes_test/screens/detection/diabetes_detection_screen.dart';
import 'package:diabetes_test/screens/home/widgets/action_card.dart';
import 'package:diabetes_test/screens/home/widgets/app_bar/home_app_bar.dart';
import 'package:diabetes_test/screens/home/widgets/article_card.dart';
import 'package:diabetes_test/screens/home/widgets/health_metrics_card.dart';
import 'package:diabetes_test/screens/home/widgets/history_card.dart';
import 'package:diabetes_test/screens/home/widgets/section_header.dart';
import 'package:diabetes_test/screens/settings/setting_screen.dart';
import 'package:diabetes_test/test_results_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:diabetes_test/providers/streak_provider.dart';


class DashboardScreen extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const DashboardScreen({super.key, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<StreakProvider>(
      builder: (context, streakProvider, _) {
        return Scaffold(
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              HomeAppBar(
                onSettingsTap:
                    () => Navigator.push(context, SettingsScreen() as Route<Object?>),
                currentStreak: context.watch<StreakProvider>().currentStreak,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HealthMetricsCard(),
                      const SizedBox(height: 24),
                      _buildDailyCheckSection(context, streakProvider),
                      const SizedBox(height: 24),
                      const TestResultsSection(),
                      const SizedBox(height: 24),
                      const ActionGrid(),
                      const SizedBox(height: 24),
                      const ArticlesList(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyCheckSection(
    BuildContext context,
    StreakProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Daily Check-in', onSeeAll: () {}),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: const Text('Complete your daily health check'),
          subtitle: const Text('Maintain your streak by checking in daily'),
          value: false,
          onChanged: (value) {
            if (value == true) {
              provider.incrementStreak();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Streak updated! Keep it going!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          secondary: const Icon(Icons.health_and_safety_rounded),
          tileColor: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}

class TestResultsSection extends StatelessWidget {
  const TestResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Consumer<TestResultsProvider>(
      builder: (context, provider, _) {
        if (provider.results.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Recent Test Results',
              onSeeAll: () => _navigateToHistory(context),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.results.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  final result = provider.results[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: HistoryCard(
                      result: result,
                      onTap: () => _showResultDetails(context, result),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToHistory(BuildContext context) {
    Provider.of<PageController>(context, listen: false).animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showResultDetails(BuildContext context, dynamic result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Test Result Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${DateFormat('MMM dd, yyyy').format(result.date)}'),
                Text('Blood Sugar: ${result.glucoseLevel} mg/dL'),
                Text('Status: ${result.status}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class ActionGrid extends StatelessWidget {
  const ActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Quick Actions', onSeeAll: () {}),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            ActionCard(
              icon: Icons.camera_alt_rounded,
              title: 'New Scan',
              color: Colors.blue,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DiabetesDetectionScreen(),
                    ),
                  ),
            ),
            ActionCard(
              icon: Icons.history_rounded,
              title: 'View History',
              color: Colors.purple,
              onTap: () => _navigateToHistory(context),
            ),
            ActionCard(
              icon: Icons.article_rounded,
              title: 'Health Tips',
              color: Colors.orange,
              onTap: () {},
            ),
            ActionCard(
              icon: Icons.settings_rounded,
              title: 'Settings',
              color: Colors.teal,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToHistory(BuildContext context) {
    Provider.of<PageController>(context, listen: false).animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

class ArticlesList extends StatelessWidget {
  const ArticlesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Health Articles', onSeeAll: () {}),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ArticleCard(
                title: 'Managing Diabetes Naturally',
                imageAsset: 'assets/images/healthy_food.jpeg',
                onTap: () {},
              ),
              const SizedBox(width: 12),
              ArticleCard(
                title: 'Exercise Benefits',
                imageAsset: 'assets/images/exercise.jpeg',
                onTap: () {},
              ),
              const SizedBox(width: 12),
              ArticleCard(
                title: 'Blood Sugar Monitoring',
                imageAsset: 'assets/images/blood_sugar.jpeg',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

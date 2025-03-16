import 'package:diabetes_test/screens/home/widgets/history_card.dart';
import 'package:diabetes_test/test_results_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TestResultsProvider>(
      builder: (context, provider, _) {
        return CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text('Test History'),
              pinned: true,
              floating: true,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => HistoryCard(result: provider.results[index]),
                childCount: provider.results.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
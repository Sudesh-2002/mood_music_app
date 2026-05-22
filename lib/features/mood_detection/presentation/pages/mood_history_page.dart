import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/mood_constants.dart';
import '../../data/datasources/mood_history_datasource.dart';
import '../../data/models/mood_history_model.dart';

class MoodHistoryPage extends StatefulWidget {
  const MoodHistoryPage({super.key});

  @override
  State<MoodHistoryPage> createState() => _MoodHistoryPageState();
}

class _MoodHistoryPageState extends State<MoodHistoryPage> {
  List<MoodHistoryModel> _history = [];
  Map<MoodLabel, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _history = MoodHistoryDataSource().getHistory();
      _counts = MoodHistoryDataSource().getMoodCounts();
    });
  }

  Color _moodColor(MoodLabel mood) {
    switch (mood) {
      case MoodLabel.happy:     return AppColors.moodHappy;
      case MoodLabel.sad:       return AppColors.moodSad;
      case MoodLabel.angry:     return AppColors.moodAngry;
      case MoodLabel.neutral:   return AppColors.moodNeutral;
      case MoodLabel.surprised: return AppColors.moodSurprised;
      case MoodLabel.fearful:   return AppColors.moodFearful;
      case MoodLabel.disgusted: return AppColors.moodDisgusted;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: const Text('Mood History',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold)),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.textSecondary),
              onPressed: () async {
                await MoodHistoryDataSource().clearHistory();
                _load();
              },
              tooltip: 'Clear history',
            ),
        ],
      ),
      body: _history.isEmpty
          ? _buildEmpty()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChart(),
                  const SizedBox(height: 24),
                  _buildMoodBreakdown(),
                  const SizedBox(height: 24),
                  const Text('Recent scans',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 12),
                  ..._history.map(_buildHistoryItem),
                ],
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('😐', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text('No mood history yet',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Scan your mood to start tracking',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final total = _counts.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mood distribution',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _counts.values
                    .fold(0, (a, b) => a > b ? a : b)
                    .toDouble() +
                    1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final mood = MoodLabel.values[val.toInt()];
                        return Text(mood.emoji,
                            style: const TextStyle(fontSize: 14));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: MoodLabel.values.asMap().entries.map((e) {
                  final mood = e.value;
                  final count = _counts[mood] ?? 0;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: _moodColor(mood),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodBreakdown() {
    final total = _counts.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    // Find dominant mood
    final dominant = _counts.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Summary',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(dominant.key.emoji,
                  style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Most frequent mood',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12)),
                  Text(dominant.key.displayName,
                      style: TextStyle(
                          color: _moodColor(dominant.key),
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$total',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const Text('total scans',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(MoodHistoryModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(item.mood.emoji,
              style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.mood.displayName,
                    style: TextStyle(
                        color: _moodColor(item.mood),
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                Text(
                    '${(item.confidence * 100).toStringAsFixed(0)}% confidence',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12)),
              ],
            ),
          ),
          Text(_timeAgo(item.detectedAt),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/quick_stat.dart';

class QuickInsightsPills extends StatelessWidget {
  final List<QuickStat> stats;

  const QuickInsightsPills({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _buildStatPill(context, stats[index]),
      ),
    );
  }

  Widget _buildStatPill(BuildContext context, QuickStat stat) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: stat.onTap != null
          ? () {
        HapticFeedback.selectionClick();
        stat.onTap!();
      }
          : null,
      borderRadius: BorderRadius.circular(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 120, // limit height to prevent overflow
          minHeight: 80,  // optional minimum height
        ),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: stat.backgroundColor, // ✅ use backgroundColor from QuickStat
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: stat.color.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: isDark
                ? []
                : [
              BoxShadow(
                color: stat.color.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: stat.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      stat.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stat.value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: stat.color,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
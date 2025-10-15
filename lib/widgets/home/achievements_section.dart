import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../provider/simplified_gamification.dart';

class AchievementsSection extends StatefulWidget {
  final List<Achievement> achievements;

  const AchievementsSection({
    super.key,
    required this.achievements,
  });

  @override
  State<AchievementsSection> createState() => _AchievementsSectionState();
}

class _AchievementsSectionState extends State<AchievementsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unlockedCount = widget.achievements.where((a) => a.isUnlocked).length;
    final hasReward = widget.achievements.any((a) => a.isUnlocked && a.progress >= 1.0);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isExpanded = !_isExpanded);
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Text('🏅', style: TextStyle(fontSize: 22)),
                      if (hasReward)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'achievements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Text(
                    '$unlockedCount/${widget.achievements.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  ...widget.achievements.asMap().entries.map((entry) {
                    final i = entry.key;
                    final ach = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(top: i > 0 ? 12 : 0),
                      child: _buildAchievementRow(context, ach),
                    );
                  }),
                ],
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementRow(BuildContext context, Achievement ach) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: ach.isUnlocked
                ? LinearGradient(
              colors: [ach.color, ach.color.withOpacity(0.7)],
            )
                : null,
            color: ach.isUnlocked ? null : ach.color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            ach.icon,
            color: ach.isUnlocked ? Colors.white : ach.color.withOpacity(0.5),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ach.title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: ach.isUnlocked
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              if (!ach.isUnlocked) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 6,
                    child: Stack(
                      children: [
                        Container(color: colorScheme.surfaceContainerHighest),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              width: constraints.maxWidth * ach.progress,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [ach.color, ach.color.withOpacity(0.7)],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (ach.isUnlocked)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF43E97B).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF43E97B),
              size: 16,
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ach.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${ach.current}/${ach.target}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: ach.color,
              ),
            ),
          ),
      ],
    );
  }
}
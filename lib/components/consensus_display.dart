import 'package:estimation_tool/models/vote.dart';
import 'package:estimation_tool/theme/obsidian_tokens.dart';
import 'package:flutter/material.dart';

class ConsensusDisplay extends StatelessWidget {
  const ConsensusDisplay({
    super.key,
    required this.votes,
    required this.showVotes,
    required this.userCount,
  });

  final Map<String, Vote> votes;
  final bool showVotes;
  final int userCount;

  @override
  Widget build(BuildContext context) {
    final tokens = context.obsidianTokens;
    final counts = <StoryPoint, int>{
      for (final point in StoryPoint.values) point: 0,
    };

    for (final vote in votes.values) {
      counts[vote.storyPoint] = (counts[vote.storyPoint] ?? 0) + 1;
    }

    final maxCount = userCount > 0 ? userCount : 1;
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final consensusLabel = showVotes && sorted.first.value > 0
        ? sorted.first.key.label
        : '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: tokens.surfacePanel,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CONSENSUS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.1,
                    color: tokens.onSurfaceMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  consensusLabel,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: tokens.onSurfaceStrong,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: StoryPoint.values.map((point) {
                  final count = counts[point] ?? 0;
                  final normalized = showVotes ? (count / maxCount) : 0.0;
                  final barHeight = (normalized * 96).clamp(6.0, 96.0);
                  final highlight = point.label == consensusLabel && consensusLabel != '-';

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: highlight ? tokens.chartBarTouched : tokens.chartBar,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            point.label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: tokens.onSurfaceMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

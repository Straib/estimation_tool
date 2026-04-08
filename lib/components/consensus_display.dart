import 'dart:math';

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

  static const List<String> _hiddenConsensusEmojis = <String>[
    '🤔',
    '🎲',
    '🫣',
    '🃏',
    '🎯',
    '🧠',
    '✨',
  ];

  @override
  Widget build(BuildContext context) {
    return _ConsensusDisplayView(
      votes: votes,
      showVotes: showVotes,
      userCount: userCount,
    );
  }
}

class _ConsensusDisplayView extends StatefulWidget {
  const _ConsensusDisplayView({
    required this.votes,
    required this.showVotes,
    required this.userCount,
  });

  final Map<String, Vote> votes;
  final bool showVotes;
  final int userCount;

  @override
  State<_ConsensusDisplayView> createState() => _ConsensusDisplayViewState();
}

class _ConsensusDisplayViewState extends State<_ConsensusDisplayView> {
  late String _hiddenConsensusLabel;

  @override
  void initState() {
    super.initState();
    _hiddenConsensusLabel = _pickHiddenEmoji();
  }

  @override
  void didUpdateWidget(covariant _ConsensusDisplayView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reroll only when we transition from revealed back to hidden.
    if (oldWidget.showVotes && !widget.showVotes) {
      _hiddenConsensusLabel = _pickHiddenEmoji();
    }
  }

  String _pickHiddenEmoji() {
    final emojis = ConsensusDisplay._hiddenConsensusEmojis;
    return emojis[Random().nextInt(emojis.length)];
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.obsidianTokens;
    final counts = <StoryPoint, int>{
      for (final point in StoryPoint.values) point: 0,
    };

    for (final vote in widget.votes.values) {
      counts[vote.storyPoint] = (counts[vote.storyPoint] ?? 0) + 1;
    }

    final maxCount = widget.userCount > 0 ? widget.userCount : 1;

    StoryPoint? consensusPoint;
    var highestVoteCount = 0;

    if (widget.showVotes) {
      for (final point in StoryPoint.values) {
        final voteCount = counts[point] ?? 0;
        final isBetterCount = voteCount > highestVoteCount;
        final isTieButHigherPoint =
            voteCount == highestVoteCount &&
            voteCount > 0 &&
            (consensusPoint == null || point.index > consensusPoint.index);

        if (isBetterCount || isTieButHigherPoint) {
          highestVoteCount = voteCount;
          consensusPoint = point;
        }
      }
    }

    final consensusLabel = widget.showVotes && consensusPoint != null
      ? consensusPoint.label
      : _hiddenConsensusLabel;

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
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  consensusLabel,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: tokens.onSurfaceStrong,
                    fontWeight: FontWeight.w700,
                    fontSize: 60,
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
                  final normalized = widget.showVotes ? (count / maxCount) : 0.1;
                  final barHeight = (normalized * 96).clamp(4.0, 96.0);
                  final highlight = widget.showVotes && point == consensusPoint;

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
                              fontSize: 12,
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

import 'package:estimation_tool/models/user.dart';
import 'package:estimation_tool/models/vote.dart';
import 'package:flutter/material.dart';

class UserVoteTile extends StatelessWidget {
  const UserVoteTile({
    super.key,
    required this.user,
    required this.vote,
    required this.isDisabled,
    required this.onVote,
    required this.currentUser,
    required this.isMutating,
    required this.openNewUserPopup,
  });

  final User user;
  final Vote? vote;
  final User? currentUser;
  final bool isMutating;
  final bool isDisabled;
  final ValueChanged<StoryPoint> onVote;
  final VoidCallback openNewUserPopup;

  @override
  Widget build(BuildContext context) {
    const int columns = 5;
    const double aspectRatio = 2 / 3;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = constraints.maxWidth * 0.02;
        final double tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final double radius = tileWidth * 0.06;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
          children: StoryPoint.values.map((point) {
            final bool isSelected = vote?.storyPoint == point;
            return InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: isDisabled ? null : () => onVote(point),
              child: Card(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Center(
                  child: Text(
                    point.label,
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(
                      fontSize: tileWidth * 0.35,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

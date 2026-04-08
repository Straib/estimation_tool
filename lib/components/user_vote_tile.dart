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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            if (currentUser == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Set your name before voting.'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: isMutating ? null : openNewUserPopup,
                    child: const Text('Set my user'),
                  ),
                ],
              )
            else
              Text(user.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Vote: ${vote?.storyPoint.label ?? '-'}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  StoryPoint.values
                      .map(
                        (point) => OutlinedButton(
                          onPressed: isDisabled ? null : () => onVote(point),
                          child: Text(point.label),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

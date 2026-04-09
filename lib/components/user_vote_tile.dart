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
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children:
          StoryPoint.values
              .map(
                (point) => InkWell(
                  onTap: isDisabled ? null : () => onVote(point),
                  child: SizedBox(
                    width: 200,
                    height: 300,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            point.label,
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}

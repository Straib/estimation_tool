import 'package:estimation_tool/models/session.dart';
import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  const UserList({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final minHeight = MediaQuery.of(context).size.height * 0.5;

    return Align(
      alignment: Alignment.topRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 300,
          minHeight: minHeight,
        ),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text('Participants', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (session.users.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('No participants yet.'),
                )
              else
                ...session.users.map((user) {
                  final vote = session.voteForUser(user.id);
                  final voteDisplay =
                      session.status == SessionStatus.revealed
                          ? vote?.storyPoint.label ?? 'No vote'
                          : 'voting';
                  return ListTile(
                    title: Text(user.name),
                    trailing: Text(
                      voteDisplay,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

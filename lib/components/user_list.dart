import 'package:estimation_tool/models/session.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:web/web.dart' as web;

class UserList extends StatelessWidget {
  const UserList({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {

    void copyToClipBoard(context) {
      FlutterClipboard.copy(web.window.location.href).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL copied to clipboard')),
        );
      });
    }

    return Card(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Participants',
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
                title: Row(
                  children: [
                    Icon(Icons.person),
                    const SizedBox(width: 4),
                    Text(user.name),
                  ],
                ),
                trailing: Text(
                  voteDisplay,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ElevatedButton(
            onPressed: () => copyToClipBoard(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle),
                const SizedBox(width: 8),
                const Text('INVITE TEAM'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

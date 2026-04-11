import 'package:estimation_tool/models/session.dart';
import 'package:estimation_tool/models/vote.dart';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:web/web.dart' as web;

class UserList extends StatelessWidget {
  const UserList({super.key, required this.session});

  final Session session;

  ({String label, IconData icon, Color backgroundColor, Color foregroundColor})
  _voteCardState(Vote? vote) {
    if (session.status == SessionStatus.revealed) {
      return (
        label: vote?.storyPoint.label ?? '-',
        icon: Icons.check_circle,
        backgroundColor: const Color(0xFF2D3449),
        foregroundColor: const Color(0xFFC0C1FF),
      );
    }

    if (vote != null) {
      return (
        label: '',
        icon: Icons.check_circle,
        backgroundColor: const Color(0xFF173D2A),
        foregroundColor: const Color(0xFF8CF9B8),
      );
    }

    return (
      label: '',
      icon: Icons.hourglass_top,
      backgroundColor: const Color(0xFF060E20),
      foregroundColor: const Color(0xFF8FA9D9),
    );
  }

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
              final voteState = _voteCardState(vote);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 4),
                      Text(user.name),
                    ],
                  ),
                  trailing: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      maxWidth: 40,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      color: voteState.backgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 15.0,
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (session.status != SessionStatus.revealed)
                              Icon(
                                voteState.icon,
                                size: 16,
                                color: voteState.foregroundColor,
                              ),
                              Text(
                                voteState.label,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: voteState.foregroundColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 50),
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:estimation_tool/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:estimation_tool/services/session_page_service.dart';

class NewUserPopup extends StatefulWidget {
  const NewUserPopup({
    super.key,
    required this.sessionId,
    required this.sessionService,
    this.onEnsured,
    this.onError,
  });

  final String sessionId;
  final SessionPageService sessionService;
  final ValueChanged<SessionUserContext>? onEnsured;
  final ValueChanged<String>? onError;

  @override
  State<NewUserPopup> createState() => _NewUserPopupState();
}

class _NewUserPopupState extends State<NewUserPopup> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _joinSession() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _error = 'Name is required.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    widget.sessionService.ensureUser(
      sessionId: widget.sessionId,
      name: name,
    ).then((result) {
      if (!context.mounted) {
        return;
      }

      if (!mounted) {
        return;
      }

      if (result.isSuccess) {
        widget.onEnsured?.call(result.data!);
        Navigator.of(context).pop();
        return;
      }

      final message = result.error ?? 'Could not set current user.';
      widget.onError?.call(message);
      setState(() {
        _error = message;
        _isSubmitting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Estimation Session as:'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(hintText: 'John Estimation'),
            onSubmitted: (_) {
              if (!_isSubmitting) {
                FocusScope.of(context).unfocus();
                _joinSession();
              }
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  context.router.replaceAll([const CreateSessionRoute()]);
          },
          child: const Text('Leave'),
        ),
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () async {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              setState(() {
                _error = 'Name is required.';
              });
              return;
            }

            setState(() {
              _isSubmitting = true;
              _error = null;
            });

            _joinSession();
          },
          child: const Text('Join'),
        ),
      ],
    );
  }
}

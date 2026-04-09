import 'package:auto_route/auto_route.dart';
import 'package:estimation_tool/components/create_session_header.dart';
import 'package:estimation_tool/routes/routes.dart';
import 'package:estimation_tool/services/session_api.dart';
import 'package:estimation_tool/theme/obsidian_theme.dart';
import 'package:flutter/material.dart';
import 'package:estimation_tool/theme/obsidian_tokens.dart';

@RoutePage()
class CreateSessionPage extends StatefulWidget {
  const CreateSessionPage({super.key});

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  final SessionApi _sessionApi = SessionApi();
  final TextEditingController _sessionIdController = TextEditingController();
  final TextEditingController _sessionTitleController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _sessionIdController.dispose();
    _sessionTitleController.dispose();
    super.dispose();
  }

  Future<void> _joinSession() async {
    final sessionId = _sessionIdController.text.trim();

    if (sessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a session ID to join.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _sessionApi.getSession(sessionId);
      if (!mounted) {
        return;
      }

      context.router.replace(SessionRoute(sessionId: sessionId));
    } on SessionApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not join: ${error.message}')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not join session right now.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createSession() async {
    final title = _sessionTitleController.text.trim();
    final sessionTitle = title.isEmpty ? 'New Session' : title;

    setState(() => _isLoading = true);

    try {
      final session = await _sessionApi.createSession(title: sessionTitle);
      if (!mounted) {
        return;
      }

      context.router.replace(SessionRoute(sessionId: session.id));
    } on SessionApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create: ${error.message}')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create session right now.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CreateSessionHeader(),
      body: SafeArea(
        child: Center(
          child: Card(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Session',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _sessionIdController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Session ID',
                        hintText: 'Enter session ID to join',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DecoratedBox(
                      decoration: ObsidianTheme.ctaGradient(),
                      child: SizedBox(
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _joinSession,
                          child: const Text('Join existing session ->'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    DecoratedBox(
                      decoration: ObsidianTheme.ctaGradient(),
                      child: SizedBox(
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createSession,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.obsidianTokens.onSurfaceVariant,
                            shadowColor: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_circle, size: 16),
                              const SizedBox(width: 4),
                              const Text('Create session'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

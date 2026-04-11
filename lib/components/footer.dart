import 'package:auto_route/auto_route.dart';
import 'package:estimation_tool/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  int? _hoveredLinkIndex;

  final Uri _portfolioUri = Uri.parse('https://robinpoesselt.dev');
  final Uri _sourceUri = Uri.parse('https://github.com/Straib/estimation_tool');

  Future<void> _launchFooterLink(Uri uri) async {
    final didLaunch = await launchUrl(uri);
    if (!didLaunch && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${uri.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyMedium = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(50),
      fontSize: 15,
    );
    final bodySmall = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(50),
      fontSize: 12,
    );

    final bodyMediumHover = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: Color(0xFF8CF9B8), fontSize: 15);

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withAlpha(20),
              width: 1,
            ),
          ),
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 0,
          runSpacing: 30,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      onTap: () => _launchFooterLink(_portfolioUri),
                      onHover: (isHovering) {
                        setState(() {
                          _hoveredLinkIndex = isHovering ? 0 : null;
                        });
                      },
                      child: Text(
                        'Portfolio',
                        style:
                            _hoveredLinkIndex == 0
                                ? bodyMediumHover
                                : bodyMedium,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      onTap: () => _launchFooterLink(_sourceUri),
                      onHover: (isHovering) {
                        setState(() {
                          _hoveredLinkIndex = isHovering ? 1 : null;
                        });
                      },
                      child: Text(
                        'Source',
                        style:
                            _hoveredLinkIndex == 1
                                ? bodyMediumHover
                                : bodyMedium,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      onTap:
                          () => context.router.replaceAll([
                            const ImpressumRoute(),
                          ]),
                      onHover: (isHovering) {
                        setState(() {
                          _hoveredLinkIndex = isHovering ? 2 : null;
                        });
                      },
                      child: Text(
                        'Impressum',
                        style:
                            _hoveredLinkIndex == 2
                                ? bodyMediumHover
                                : bodyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 200,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Made with ❤️ by Robin Pösselt',
                      style: bodySmall,
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('ESTIMATION_TOOL', style: bodySmall),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('v. 0.2.0', style: bodySmall),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

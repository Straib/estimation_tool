import 'package:auto_route/auto_route.dart';
import 'package:estimation_tool/routes/routes.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ImpressumPage extends StatelessWidget {
  const ImpressumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          focusColor: Colors.transparent,
          onTap: () => context.router.replaceAll([const CreateSessionRoute()]),
          child: const Text('Impressum'),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Angaben gemäß § 5 TMG:\n\n'
          'Robin Pösselt\n'
          'Grubetstr. 40\n'
          '86551 Aichach\n\n'
          'Kontakt:\n'
          'E-Mail: r.poesselt@googlemail.com',
        ),
      ),
    );
  }
}

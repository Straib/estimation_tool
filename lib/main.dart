import 'package:estimation_tool/routes/routes.dart';
import 'package:estimation_tool/theme/obsidian_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rearch/flutter_rearch.dart';

void main() {
  runApp(RearchBootstrapper(child: const MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.config(),
      themeMode: ThemeMode.dark,
      theme: ObsidianTheme.dark(),
      darkTheme: ObsidianTheme.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:artun_flutter_project/model/app_state_maneger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation/app_router.dart';

void main() {
  runApp(
    const ArtunApp(),
  );
}

class ArtunApp extends StatefulWidget {
  const ArtunApp({super.key});

  @override
  State<ArtunApp> createState() => _ArtunAppState();
}

class _ArtunAppState extends State<ArtunApp> {
  final _appStateManager = AppStateManager();
  late AppRouter _appRouter;

  @override
  void initState() {
    _appRouter = AppRouter(
      appStateManager: _appStateManager,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => _appStateManager,
        )
      ],
      child: MaterialApp(
        title: 'Artun App',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: Router(
          routerDelegate: _appRouter,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      ),
    );
  }
}

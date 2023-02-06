import 'package:artun_flutter_project/constants.dart';
import 'package:artun_flutter_project/utilities/app_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ArtunApp());
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
          primarySwatch: Colors.red,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: projectCyan,
              disabledBackgroundColor: Colors.grey[100],
            ),
          ),
        ),
        home: Router(
          routerDelegate: _appRouter,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      ),
    );
  }
}

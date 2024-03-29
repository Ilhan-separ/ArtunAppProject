import 'package:artun_flutter_project/model/app_pages.dart';
import 'package:artun_flutter_project/utilities/app_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static MaterialPage page() {
    return MaterialPage(
      name: AppPages.splashPath,
      key: ValueKey(AppPages.splashPath),
      child: const SplashScreen(),
    );
  }

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<AppStateManager>(context, listen: false).initializedApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: Provider.of<AppStateManager>(context).isAlreadyLogged(),
            builder: (context, snapshot) => const Text(""),
          ),
          Image(
            image: AssetImage('assets/artun_iha.png'),
            height: MediaQuery.of(context).size.height * .3,
            width: MediaQuery.of(context).size.width * .70,
          ),
          const SizedBox(
            height: 24.0,
          ),
          const CircularProgressIndicator(),
        ],
      )),
    );
  }
}

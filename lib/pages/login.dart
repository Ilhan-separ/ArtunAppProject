import 'package:artun_flutter_project/model/app_pages.dart';
import 'package:artun_flutter_project/model/app_state_maneger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  static MaterialPage page() {
    return MaterialPage(
      name: AppPages.loginPath,
      key: ValueKey(AppPages.loginPath),
      child: const LoginPage(),
    );
  }

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: TextButton(
            child: Text('Login'),
            onPressed: () async {
              Provider.of<AppStateManager>(context, listen: false)
                  .login('mockUsername', 'mockPassword');
            },
          ),
        ),
      ), //TODO: iki ayrı kullanıcı girişi olucak.
    );
  }
}

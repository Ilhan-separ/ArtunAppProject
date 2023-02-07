import 'package:artun_flutter_project/constants.dart';
import 'package:artun_flutter_project/model/app_pages.dart';
import 'package:artun_flutter_project/utilities/app_state_manager.dart';
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
  String loginText = "Login Page";
  bool isAlert = false;

  Widget buildLoginText(context) {
    return Text(
      loginText,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }

  String kullanciAdi = "";
  String password = "";
  @override
  Widget build(BuildContext context) {
    isAlert = Provider.of<AppStateManager>(
      context,
    ).isLoginThrowAlert;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    child: Image.asset("assets/ic_login_topImage.png"),
                    height: MediaQuery.of(context).size.height * .25,
                  ),
                ],
              ),
              Image.asset(
                "assets/ic_login_mainImage.png",
                height: MediaQuery.of(context).size.height * .15,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          kullanciAdi = value;
                        });
                      },
                      decoration: _customTextFieldDecoration("Kullanıcı Adı"),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                      obscureText: true,
                      decoration: _customTextFieldDecoration("Şifre"),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    isAlert ? Text("Yanlış bilgi girildi.") : Center(),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: projectCyan,
                ),
                onPressed: () {
                  if (kullanciAdi.contains("k")) {
                    _kizilayLoginOnPressed(context, kullanciAdi, password);
                  } else {
                    _talepciLoginOnPressed(context, kullanciAdi, password);
                  }
                },
                child: Text("Giriş Yap"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    child: Image.asset("assets/ic_login_bottomImage.png"),
                    height: MediaQuery.of(context).size.height * .25,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _customTextFieldDecoration(String label) {
    return InputDecoration(
      alignLabelWithHint: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(
          color: projectRed,
        ),
      ),
      floatingLabelAlignment: FloatingLabelAlignment.start,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      label: Text(label),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  void _talepciLoginOnPressed(
      BuildContext context, String kullanciAdi, String password) {
    Provider.of<AppStateManager>(context, listen: false)
        .loginForT(kullanciAdi, password);
  }

  void _kizilayLoginOnPressed(
      BuildContext context, String kullanciAdi, String password) {
    Provider.of<AppStateManager>(context, listen: false)
        .loginForK(kullanciAdi, password);
  }
}

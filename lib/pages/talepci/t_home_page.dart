import 'package:artun_flutter_project/model/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../model/app_state_maneger.dart';

class THomePage extends StatefulWidget {
  static MaterialPage page() {
    return MaterialPage(
      name: AppPages.tHome,
      key: ValueKey(AppPages.tHome),
      child: THomePage(),
    );
  }

  const THomePage({super.key});

  @override
  State<THomePage> createState() => _THomePageState();
}

class _THomePageState extends State<THomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Talep Ana Sayfa',
            ),
            ElevatedButton(
              child: Text('Logout'),
              onPressed: () async {
                Provider.of<AppStateManager>(context, listen: false).logout();
              },
            ),
          ],
        )),
      ),
    );
  }
}

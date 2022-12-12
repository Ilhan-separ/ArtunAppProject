import 'package:artun_flutter_project/map.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home:
          Map(), //TODO: Talep listesi, talep listesinden haritaya geçiş haritada drone gerçek zamanlı gözüksün.
    );
  }
}

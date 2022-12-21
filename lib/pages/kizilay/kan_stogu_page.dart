import 'package:flutter/material.dart';

class KanStokPage extends StatefulWidget {
  const KanStokPage({super.key});

  @override
  State<KanStokPage> createState() => _KanStokPageState();
}

class _KanStokPageState extends State<KanStokPage> {
  List<String> bloodList = [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (var i = 0; i < bloodList.length; i++)
          ListTile(
            title: Text(bloodList[i]),
            trailing: Text("24"),
          )
      ],
    );
  }
}

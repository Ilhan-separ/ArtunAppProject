import 'package:artun_flutter_project/mapMockup.dart';
import 'package:artun_flutter_project/view/details_page.dart';
import 'package:flutter/material.dart';

import '../../widgets/talep_tile.dart';

class TalepciTaleplerPage extends StatefulWidget {
  const TalepciTaleplerPage({super.key});

  @override
  State<TalepciTaleplerPage> createState() => _TalepciTaleplerPageState();
}

class _TalepciTaleplerPageState extends State<TalepciTaleplerPage> {
  List<String> listId = [
    "selam",
    "naber",
    "aynn",
    "çok şey yapma",
    "olur öyle",
    "falan denir",
    "xd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
    "asd",
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: listId.length,
      padding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0, top: 4.0),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const DetailsPage(),
              ),
            );
          },
          child: TalepTile(
            talepEden: "Talep Eden",
            talepDetayi: "Talep Detayları...",
          ),
        );
      },
    );
  }
}

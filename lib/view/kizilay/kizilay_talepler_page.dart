import 'package:artun_flutter_project/mapMockup.dart';
import 'package:artun_flutter_project/view/details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/talep_tile.dart';

class KizilayTaleplerPage extends StatefulWidget {
  const KizilayTaleplerPage({super.key});

  @override
  State<KizilayTaleplerPage> createState() => _KizilayTaleplerPageState();
}

class _KizilayTaleplerPageState extends State<KizilayTaleplerPage> {
  final db = FirebaseFirestore.instance;
  final Stream<QuerySnapshot> talepRef =
      FirebaseFirestore.instance.collection("Talepler").snapshots();

  int? talepListLenght = 0;
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
    return StreamBuilder(
        stream: talepRef,
        builder: (context, snapshot) {
          talepListLenght = snapshot.data?.docs.length;

          return snapshot.hasData
              ? GridView.builder(
                  itemCount: talepListLenght,
                  padding: EdgeInsets.only(
                      left: 12.0, right: 12.0, bottom: 8.0, top: 4.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    final docData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DetailsPage(),
                          ),
                        );
                      },
                      child: TalepTile(
                        talepEden: docData["kanGrubu"],
                        talepDetayi: "Talep Detayları...",
                      ),
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }
}

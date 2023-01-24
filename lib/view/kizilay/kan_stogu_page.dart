import 'dart:math';

import 'package:artun_flutter_project/model/kizilay_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KanStokPage extends StatefulWidget {
  const KanStokPage({super.key});

  @override
  State<KanStokPage> createState() => _KanStokPageState();
}

class _KanStokPageState extends State<KanStokPage> {
  final db = FirebaseFirestore.instance;
  Stream<DocumentSnapshot> kizilayRef = FirebaseFirestore.instance
      .collection("KizilayUsers")
      .doc("User1")
      .snapshots();

//Tek seferlik okumalar için
  Future<Kizilay?> dbRead() async {
    final kizilayRef = db.collection("KizilayUsers").doc("User1").withConverter(
          fromFirestore: Kizilay.fromFirestore,
          toFirestore: (Kizilay kizilay, _) => kizilay.toFirestore(),
        );

    // DATAYI ÇEKİP PRİNTLİYOR
    // final kizilay = db.collection("KizilayUsers");
    // await kizilay.doc("User1").get().then(
    //   (DocumentSnapshot doc) {
    //     final data = doc.data() as Map<String, dynamic>;
    //     print(data);
    //   },
    //   onError: (e) => print("Erorrr!! : $e"),
    // );
  }

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
    return StreamBuilder(
      stream: kizilayRef,
      builder: (context, snapshot) {
        final docData = snapshot.data as DocumentSnapshot;
        final kanList = docData['kanStogu'] as Map<String, dynamic>;

        return ListView.separated(
          itemCount: bloodList.length,
          separatorBuilder: (context, index) {
            return const Divider(
              height: 12,
              thickness: 2,
            );
          },
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                bloodList[index],
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 42,
                    color: Color(0xFFF48634),
                  ),
                ),
              ),
              //trailing: Text("${snapshot.data?.stok![bloodList[index]]}",
              trailing: Text("${kanList[bloodList[index]]}",
                  style: TextStyle(fontSize: 12)),
            );
          },
        );
      },
    );
  }
}

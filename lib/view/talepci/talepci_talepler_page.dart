import 'package:artun_flutter_project/mapMockup.dart';
import 'package:artun_flutter_project/utilities/app_state_manager.dart';
import 'package:artun_flutter_project/view/details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/talep_tile.dart';

class TalepciTaleplerPage extends StatefulWidget {
  const TalepciTaleplerPage({super.key});

  @override
  State<TalepciTaleplerPage> createState() => _TalepciTaleplerPageState();
}

class _TalepciTaleplerPageState extends State<TalepciTaleplerPage> {
  final Stream<QuerySnapshot> talepRef =
      FirebaseFirestore.instance.collection("Talepler").snapshots();
  int? talepListLenght = 0;

  String _currentUserId = "";
  bool lateCheck = false;
  Map<int, Map<String, dynamic>> userSpesificTalepList = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: talepRef,
        builder: (context, snapshot) {
          _currentUserId =
              Provider.of<AppStateManager>(context).getCurrentUserID;
          FirebaseFirestore.instance
              .collection("Talepler")
              .where("talepEdenID", isEqualTo: _currentUserId)
              .get()
              .then((value) async {
            talepListLenght = value.docs.length;
            for (var i = 0; i < talepListLenght!; i++) {
              userSpesificTalepList.addAll({i: value.docs[i].data()});
            }
            print(userSpesificTalepList);
          });
          print("aaaaaaaaa $talepListLenght");
          print("aaaaaaaaa $_currentUserId");

          if (snapshot.hasData &&
              userSpesificTalepList != null &&
              talepListLenght != 0) {
            lateCheck = true;
          } else {
            lateCheck = false;
          }

          return lateCheck
              ? GridView.builder(
                  itemCount: talepListLenght,
                  padding: const EdgeInsets.only(
                      left: 12.0, right: 12.0, bottom: 8.0, top: 4.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
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
                        talepEden: userSpesificTalepList[index]!["kanGrubu"],
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

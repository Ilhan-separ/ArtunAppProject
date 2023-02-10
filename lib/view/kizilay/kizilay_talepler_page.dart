import 'package:artun_flutter_project/utilities/app_state_manager.dart';
import 'package:artun_flutter_project/view/details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../widgets/talep_tile.dart';

class KizilayTaleplerPage extends StatefulWidget {
  const KizilayTaleplerPage({super.key});

  @override
  State<KizilayTaleplerPage> createState() => _KizilayTaleplerPageState();
}

class _KizilayTaleplerPageState extends State<KizilayTaleplerPage> {
  final Stream<QuerySnapshot> talepRef =
      FirebaseFirestore.instance.collection("Talepler").snapshots();
  int? talepListLenght = 0;

  String _currentUserId = "";
  bool lateCheck = false;
  bool isTalepExist = true;
  Map<int, Map<String, dynamic>> userSpesificTalepList = {};

  Future<void> userSpesificListFunc() async {
    await FirebaseFirestore.instance
        .collection("Talepler")
        .where("kizilayID", isEqualTo: _currentUserId)
        .get()
        .then((value) async {
      talepListLenght = value.docs.length;
      for (var i = 0; i < talepListLenght!; i++) {
        userSpesificTalepList.addAll({i: value.docs[i].data()});
      }
    });
    if (userSpesificTalepList.isEmpty) {
      if (mounted) {
        setState(() {
          isTalepExist = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isTalepExist = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: talepRef,
        builder: (context, snapshot) {
          _currentUserId = Provider.of<AppStateManager>(context, listen: false)
              .getCurrentUserID;
          userSpesificListFunc();

          if (snapshot.hasData &&
              userSpesificTalepList.isNotEmpty &&
              talepListLenght != 0) {
            lateCheck = true;
          } else {
            lateCheck = false;
          }

          if (!isTalepExist) {
            return Center(
              child: Text(
                "Talep Bulunmuyor",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          } else {
            return lateCheck
                ? GridView.builder(
                    physics: ClampingScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: talepListLenght,
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, bottom: 8.0, top: 4.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 28 / 28),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                userSpesicifTalepList:
                                    userSpesificTalepList[index],
                                kizilayLat: userSpesificTalepList[index]![
                                    dbDocKizilayLat],
                                kizilayLng: userSpesificTalepList[index]![
                                    dbDocKizilayLng],
                                talepciLat: userSpesificTalepList[index]![
                                    dbDocTalepEdenLat],
                                talepciLng: userSpesificTalepList[index]![
                                    dbDocTalepEdenLng],
                              ),
                            ),
                          );
                        },
                        child: TalepTile(
                          talepEden: userSpesificTalepList[index]!["talepEden"],
                          kanGrubu: userSpesificTalepList[index]!["kanGrubu"],
                          unite: userSpesificTalepList[index]!["unite"],
                          durum: userSpesificTalepList[index]!["durum"],
                          talepSaati:
                              userSpesificTalepList[index]!["olusturmaSaati"],
                        ),
                      );
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          }
        });
  }
}

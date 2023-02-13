import 'dart:async';

import 'package:artun_flutter_project/constants.dart';
import 'package:artun_flutter_project/utilities/app_state_manager.dart';
import 'package:artun_flutter_project/view/details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  DatabaseReference liveLocationLatRef =
      FirebaseDatabase.instance.ref("Live/live_location_lat");
  DatabaseReference liveLocationLngRef =
      FirebaseDatabase.instance.ref("Live/live_location_long");

  late StreamSubscription<DatabaseEvent> liveLatListen;
  late StreamSubscription<DatabaseEvent> liveLngListen;

  String _currentUserId = "";
  bool lateCheck = false;
  bool isTalepExist = true;
  Map<int, Map<String, dynamic>> userSpesificTalepList = {};

  Future<void> userSpesificListFunc() async {
    await FirebaseFirestore.instance
        .collection("Talepler")
        .where("talepEdenID", isEqualTo: _currentUserId)
        .get()
        .then((value) async {
      talepListLenght = value.docs.length;
      for (var i = 0; i < talepListLenght!; i++) {
        userSpesificTalepList.addAll({i: value.docs[i].data()});
      }
    });
    if (userSpesificTalepList.isEmpty) {
      setState(() {
        isTalepExist = false;
      });
    } else {
      setState(() {
        isTalepExist = true;
      });
    }
  }

  bool isFinish = false;
  bool latValue = false;
  bool lngValue = false;
  bool listenLiveLoc(lat, lng) {
    liveLatListen = liveLocationLatRef.onValue.listen(
      (event) {
        final data = event.snapshot.value;
        if (lat == data) {
          if (mounted) {
            setState(() {
              latValue = true;
            });
          }
        }
      },
    );

    liveLngListen = liveLocationLngRef.onValue.listen(
      (event) {
        final data = event.snapshot.value;
        if (lng == data) {
          if (mounted) {
            setState(() {
              lngValue = true;
            });
          }
        }
      },
    );

    if (latValue == true && lngValue == true) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    liveLatListen.cancel();
    liveLngListen.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: talepRef,
        builder: (context, snapshot) {
          _currentUserId =
              Provider.of<AppStateManager>(context).getCurrentUserID;

          userSpesificListFunc();

          if (snapshot.hasData &&
              userSpesificTalepList != null &&
              talepListLenght != 0) {
            for (var i = 0; i < userSpesificTalepList.length; i++) {
              if (userSpesificTalepList[i]!["durum"] == "vardı") {
                isFinish = listenLiveLoc(
                    userSpesificTalepList[i]!["kizilayLat"],
                    userSpesificTalepList[i]!["kizilayLng"]);
                if (isFinish) {
                  FirebaseFirestore.instance
                      .collection("Talepler")
                      .doc(userSpesificTalepList[i]!["id"])
                      .delete()
                      .then((value) => print("başarılı bir şekilde silindi."));
                }
                print(
                    "Takipteki varan drone : $isFinish ,,,,,, ${userSpesificTalepList[i]!["id"]}");
              }
            }
            lateCheck = true;
          } else {
            lateCheck = false;
          }

          if (!isTalepExist) {
            return Center(
              child: Text(
                "Talep Bulunmuyor",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: projectRed,
                    fontFamily: GoogleFonts.roboto().fontFamily),
              ),
            );
          } else {
            return lateCheck
                ? GridView.builder(
                    itemCount: talepListLenght,
                    padding: const EdgeInsets.only(
                        left: 12.0, right: 12.0, bottom: 8.0, top: 4.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 28 / 28),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                userSpesificTalepList:
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
                          talepEden: userSpesificTalepList[index]!["kizilay"],
                          kanGrubu: userSpesificTalepList[index]!["kanGrubu"],
                          unite: userSpesificTalepList[index]!["unite"],
                          durum: userSpesificTalepList[index]!["durum"],
                          talepSaati:
                              userSpesificTalepList[index]!["olusturmaSaati"],
                        ),
                      );
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          }
        });
  }
}

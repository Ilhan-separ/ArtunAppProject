import 'package:artun_flutter_project/constants.dart';
import 'package:artun_flutter_project/model/kizilay_model.dart';
import 'package:artun_flutter_project/utilities/app_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class KanStokPage extends StatefulWidget {
  const KanStokPage({super.key});

  @override
  State<KanStokPage> createState() => _KanStokPageState();
}

class _KanStokPageState extends State<KanStokPage> {
  String user = "a";

  final db = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Object?>>? dbCall(user) {
    Stream<DocumentSnapshot> kizilayRef = FirebaseFirestore.instance
        .collection("KizilayUsers")
        .doc(user)
        .snapshots();

    return kizilayRef;
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
    Size mediaSize = MediaQuery.of(context).size;
    user =
        Provider.of<AppStateManager>(context, listen: false).getCurrentUserID;
    return StreamBuilder(
      stream: dbCall(user),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.separated(
                padding: EdgeInsets.all(12),
                itemCount: bloodList.length,
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: mediaSize.height * .030,
                  );
                },
                itemBuilder: (context, index) {
                  final docData = snapshot.data as DocumentSnapshot;
                  final fromFirebaseKanStogu =
                      docData['kanStogu'] as Map<String, dynamic>;
                  return Container(
                    //Bütün Tile Containerı
                    padding:
                        EdgeInsets.only(top: 10, bottom: 10, left: 4, right: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: projectRed,
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                            color: Color.fromARGB(50, 0, 0, 0),
                            offset: Offset(1, 2),
                            blurRadius: 3.2,
                            spreadRadius: 0.2),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        //Kan Gurubu Containerı
                        width: mediaSize.width * .17,
                        decoration: BoxDecoration(
                          color: projectCyan,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromARGB(50, 0, 0, 0),
                                offset: Offset(1, 2),
                                blurRadius: 3.2,
                                spreadRadius: 0.2),
                          ],
                        ),
                        child: Center(
                          child: SizedBox(
                            child: Text(
                              bloodList[index],
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontSize: mediaSize.width * .066,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                      trailing: Text(
                        "${fromFirebaseKanStogu[bloodList[index]]}",
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                              fontSize: mediaSize.width * .072,
                              color: projectRed,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
}

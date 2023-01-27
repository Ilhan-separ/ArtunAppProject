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
        .doc(user) //Döküman ismi giriş yapışınca telefonda tutulacak.
        .snapshots();

    return kizilayRef;
  }

//Tek seferlik okumalar için -unused
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
    user = Provider.of<AppStateManager>(context).getCurrentUser;
    return StreamBuilder(
      stream: dbCall(user),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.separated(
                padding: EdgeInsets.all(12),
                itemCount: bloodList.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 24,
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
                        width: 64,
                        decoration: BoxDecoration(
                          color: Colors.cyan,
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
                                textStyle: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      trailing: Text(
                        "${fromFirebaseKanStogu[bloodList[index]]}",
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                              fontSize: 28,
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

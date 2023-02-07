import 'package:artun_flutter_project/constants.dart';
import 'package:artun_flutter_project/utilities/app_state_manager.dart';
import 'package:artun_flutter_project/view/talepci/talep_ayrinti_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class KanTalepScreen extends StatefulWidget {
  const KanTalepScreen({super.key});

  @override
  State<KanTalepScreen> createState() => KanTalepScreenState();
}

class KanTalepScreenState extends State<KanTalepScreen> {
  final taleplerRef = FirebaseFirestore.instance.collection("Talepler");
  final kizilayRef = FirebaseFirestore.instance.collection("KizilayUsers");
  final dbTalepMap = <String, dynamic?>{};
  Map<int, dynamic>? dbKizilayMap;
  double _currentUserLat = 1;
  double _currentUserLng = 1;

  final String _kanGrubuText = "Kan Grubunu Seçiniz:";
  final String _kanUnitesiText = "Ünite Sayısını Şeçiniz:";
  final List<String> _kanGrubuListesi = [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-",
  ];
  final List<String> _uniteSayiListesi = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
  ];

  String _selectedKanTipi = "A+";
  String _selectedUniteSayisi = '1';
  String _currentUser = "";
  String _currentUserName = "";

  List<DropdownMenuItem<String>> _addDividersAfterItems(
      List<String> items, context) {
    List<DropdownMenuItem<String>> _menuItems = [];
    for (var item in items) {
      _menuItems.addAll(
        [
          DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * .038,
                ),
              ),
            ),
          ),
          if (item != items.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(
                height: 0,
                thickness: 1,
                color: Colors.white,
              ),
            ),
        ],
      );
    }
    return _menuItems;
  }

  List<double> _getCustomItemsHeights(items) {
    List<double> _itemsHeights = [];
    for (var i = 0; i < (items.length * 2) - 1; i++) {
      _itemsHeights.add(30);
    }
    return _itemsHeights;
  }

  @override
  Widget build(BuildContext context) {
    Size mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: mediaSize.width * .014,
                ),
                Text(
                  _kanGrubuText,
                  style: GoogleFonts.robotoMono(
                    fontSize: mediaSize.width * .036,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: mediaSize.height * .018,
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                style: TextStyle(
                  fontSize: mediaSize.width * .070,
                  color: Colors.white,
                ),
                buttonDecoration: BoxDecoration(
                  color: projectCyan,
                  borderRadius: BorderRadius.circular(12),
                ),
                buttonWidth: mediaSize.width * .55,
                buttonHeight: mediaSize.height * .065,
                buttonPadding: EdgeInsets.only(left: 16, right: 10),
                buttonElevation: 1,
                dropdownElevation: 1,
                dropdownOverButton: false,
                dropdownMaxHeight: mediaSize.height * .3,
                dropdownDecoration: BoxDecoration(
                  color: projectCyan,
                  borderRadius: BorderRadius.circular(12),
                ),
                dropdownPadding:
                    EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 8),
                itemPadding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                value: _selectedKanTipi,
                items: _addDividersAfterItems(_kanGrubuListesi, context),
                customItemsHeights: _getCustomItemsHeights(_kanGrubuListesi),
                onChanged: (value) => setState(() {
                  _selectedKanTipi = value!;
                }),
              ),
            ),
            Divider(height: mediaSize.height * .050),
            Row(
              children: [
                SizedBox(
                  width: mediaSize.width * .014,
                ),
                Text(
                  _kanUnitesiText,
                  style: GoogleFonts.robotoMono(
                    fontSize: mediaSize.width * .036,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: mediaSize.height * .018,
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                style: TextStyle(
                  fontSize: mediaSize.width * .070,
                  color: Colors.white,
                ),
                buttonDecoration: BoxDecoration(
                  color: projectCyan,
                  borderRadius: BorderRadius.circular(12),
                ),
                buttonWidth: mediaSize.width * .55,
                buttonHeight: mediaSize.height * .065,
                buttonPadding: EdgeInsets.only(left: 16, right: 10),
                buttonElevation: 1,
                dropdownElevation: 1,
                dropdownOverButton: false,
                dropdownMaxHeight: mediaSize.height * .3,
                dropdownDecoration: BoxDecoration(
                  color: projectCyan,
                  borderRadius: BorderRadius.circular(12),
                ),
                dropdownPadding:
                    EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 8),
                itemPadding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                value: _selectedUniteSayisi,
                items: _addDividersAfterItems(_uniteSayiListesi, context),
                customItemsHeights: _getCustomItemsHeights(_uniteSayiListesi),
                onChanged: (value) => setState(() {
                  _selectedUniteSayisi = value!;
                }),
              ),
            ),
            SizedBox(
              height: mediaSize.height * .080,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await kizilayRef.get().then(
                      (documents) {
                        dbKizilayMap = documents.docs.asMap();
                      },
                      onError: (e) => print("Error getting document: $e"),
                    );
                    _showKanTalepDialog(context);
                  },
                  child: Text("Talepte Bulun"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: projectRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showKanTalepDialog(BuildContext context) {
    //Dialog'u burdan gösterip tüm işlemlerini burdan yapıyorum.
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return TalepAyrintiDialog(
          uniteSayisi: int.parse(_selectedUniteSayisi),
          kanGrubuText: _selectedKanTipi,
          uniteSayisiText: _selectedUniteSayisi,
          dbKizilayMap: dbKizilayMap,
        );

        // return AlertDialog(
        //   shape:
        //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        //   title: Text("Seçilenler:"),
        //   content: SingleChildScrollView(
        //     child: ListBody(
        //       children: [
        //         Text("Seçilen Kan Grubu : $_selectedKanTipi"),
        //         Text("Seçilen Ünite : $_selectedUniteSayisi ")
        //       ],
        //     ),
        //   ),
        //   actions: <Widget>[
        //     TextButton(
        //       onPressed: () => Navigator.of(context).pop(),
        //       child: Text(
        //         "Geri",
        //         style: TextStyle(
        //           color: Colors.blueGrey[400],
        //         ),
        //       ),
        //     ),
        //     TextButton(
        //       //!!!!Firebase talep listesi oluşturan  textBox!!!!

        //       onPressed: () async {
        //         _currentUser =
        //             Provider.of<AppStateManager>(context, listen: false)
        //                 .getCurrentUserID;
        //         _currentUserName =
        //             Provider.of<AppStateManager>(context, listen: false)
        //                 .getCurrentUserName;
        //         _currentUserLat =
        //             Provider.of<AppStateManager>(context, listen: false)
        //                 .getCurrentUserLat;
        //         _currentUserLng =
        //             Provider.of<AppStateManager>(context, listen: false)
        //                 .getCurrentUserLng;

        //         await kizilayRef.get().then(
        //           (documents) {
        //             dbKizilayMap = documents.docs.asMap();
        //           },
        //           onError: (e) => print("Error getting document: $e"),
        //         );
        //         //TODO: Saat formatı değişebilir.
        //         String dt = DateFormat("HH:mm").format(DateTime.now());
        //         dbTalepMap.addAll({
        //           "kanGrubu": _selectedKanTipi,
        //           "unite": _selectedUniteSayisi,
        //           "talepEdenID": _currentUser,
        //           "talepEden": _currentUserName,
        //           "talepEdenLat": _currentUserLat,
        //           "talepEdenLng": _currentUserLng,
        //           "kizilay": dbKizilayMap![1]["name"],
        //           "kizilayID": dbKizilayMap![1]["id"],
        //           "kizilayLat": dbKizilayMap![1]["lat"],
        //           "kizilayLng": dbKizilayMap![1]["lng"],
        //           "durum": "iletildi",
        //           "id": "",
        //           "olusturmaSaati": dt,
        //           "kalkisSaati": "",
        //         });
        //         taleplerRef.add(dbTalepMap).then((value) {
        //           taleplerRef.doc(value.id).update({"id": value.id});
        //           print(value.id);
        //         });
        //         Navigator.of(context).pop();
        //       },
        //       child: Text(
        //         "Talep Et",
        //         style: TextStyle(
        //             color: Colors.blueGrey[700], fontWeight: FontWeight.bold),
        //       ),
        //     ),
        //   ],
        // );
      },
    );
  }
}

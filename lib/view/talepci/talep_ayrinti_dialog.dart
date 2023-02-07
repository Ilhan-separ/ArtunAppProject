import 'package:artun_flutter_project/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../utilities/app_state_manager.dart';

class TalepAyrintiDialog extends StatefulWidget {
  final int uniteSayisi;
  final String kanGrubuText;
  final String uniteSayisiText;
  final Map<int, dynamic>? dbKizilayMap;
  const TalepAyrintiDialog(
      {super.key,
      required this.uniteSayisi,
      required this.dbKizilayMap,
      required this.kanGrubuText,
      required this.uniteSayisiText});

  @override
  State<TalepAyrintiDialog> createState() => _TalepAyrintiDialogState();
}

final taleplerRef = FirebaseFirestore.instance.collection("Talepler");
final kizilayRef = FirebaseFirestore.instance.collection("KizilayUsers");
final dbTalepMap = <String, dynamic?>{};

double _currentUserLat = 1;
double _currentUserLng = 1;
String _currentUser = "";
String _currentUserName = "";
List<String> stok = [];
bool _isStokExist = true;
int index = -2;
List<double> distance = [];
List<int> stokMevcutIndexler = [];
int optimumIndex = -1;

final String _otomatikYazisi =
    "Sistem otomatik olarak kan talebinizi karşılayabilecek kızılaya talebinizi iletecek";

class _TalepAyrintiDialogState extends State<TalepAyrintiDialog> {
  String getDistanceBetween(
      double lat1, double lat2, double lng1, double lng2) {
    var R = 6371;
    var dLat = deg2rad(lat2 - lat1);
    var dLng = deg2rad(lng2 - lng1);
    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(deg2rad(lat1)) *
            math.cos(deg2rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var d = R * c;

    return d.toStringAsFixed(2);
  }

  double deg2rad(deg) {
    return deg * (math.pi / 180);
  }

  void stokListDoldur() {
    stok = [];
    for (var i = 0; i < 3; i++) {
      print("Widget Unite Sayisi : ${widget.uniteSayisi}");
      if (widget.uniteSayisi <=
          widget.dbKizilayMap![i]["kanStogu"][widget.kanGrubuText]) {
        stok.add("Var");
      } else {
        stok.add("Yok");
      }
      print(
          "db Stok : ${widget.dbKizilayMap![i]["kanStogu"][widget.kanGrubuText]}");
      print("stok : ${stok[i]}");
    }
    _printStok();
  }

  void _printStok() {
    for (var i = 0; i < stok.length; i++) {
      print("print stokList : ${stok[i]}");
    }
  }

  int _getOptimalKizilayIndex() {
    stokMevcutIndexler = [];
    for (var i = 0; i < 3; i++) {
      if (stok[i] == "Var") {
        stokMevcutIndexler.add(i);
      }
    }

    if (stokMevcutIndexler.isEmpty) {
      setState(() {
        _isStokExist = false;
      });
      return -1;
    }

    distance = [];
    for (var i = 0; i < 3; i++) {
      var uzaklik = getDistanceBetween(
        _userLat,
        widget.dbKizilayMap![i]["lat"],
        _userLng,
        widget.dbKizilayMap![i]["lng"],
      );
      distance.add(double.parse(uzaklik));
    }
    var temp;
    if (stokMevcutIndexler.length == 1) {
      return stokMevcutIndexler[0];
    } else {
      for (var i = 0; i < stokMevcutIndexler.length; i++) {
        for (var j = 0; j < stokMevcutIndexler.length; j++) {
          print("distanclar ${distance[stokMevcutIndexler[i]]}");
          print(
              "Stok mevcut index : ${stokMevcutIndexler[i]}"); //TODO: Printleri sil stok yoksa uyarı mesajı koy.
          if (distance[stokMevcutIndexler[i]] <
              distance[stokMevcutIndexler[j]]) {
            index = stokMevcutIndexler[i];
          }
        }
      }
    }

    return index;
  }

  // void _getDistanceList(List<double> distance) {}

  // void _stokIndexBul(List<int> stokMevcutIndexler) {}

  int _kizilayIndex = 0;
  double _userLat = 1;
  double _userLng = 1;
  @override
  Widget build(BuildContext context) {
    _userLat = Provider.of<AppStateManager>(context).getCurrentUserLat;
    _userLng = Provider.of<AppStateManager>(context).getCurrentUserLng;
    stokListDoldur();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: projectRed,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _kanGrubuVeUniteRow(
                    "Seçilen Kan Grubu : ", widget.kanGrubuText),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .02,
                ),
                _kanGrubuVeUniteRow(
                    "Seçilen Ünite Sayısı : ", widget.uniteSayisiText),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .01,
                ),
                _iletildiMesajContainer(context),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: ListView(
                padding: EdgeInsets.only(top: 4),
                children: [
                  Column(
                    children: [
                      _detayContainer(
                        context,
                        widget.dbKizilayMap![0]["name"],
                        widget.dbKizilayMap![0]["arac"],
                        stok[0],
                        getDistanceBetween(
                          _userLat,
                          widget.dbKizilayMap![0]["lat"],
                          _userLng,
                          widget.dbKizilayMap![0]["lng"],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .048,
                      ),
                      _detayContainer(
                        context,
                        widget.dbKizilayMap![1]["name"],
                        widget.dbKizilayMap![1]["arac"],
                        stok[1],
                        getDistanceBetween(
                          _userLat,
                          widget.dbKizilayMap![1]["lat"],
                          _userLng,
                          widget.dbKizilayMap![1]["lng"],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .048,
                      ),
                      _detayContainer(
                        context,
                        widget.dbKizilayMap![2]["name"],
                        widget.dbKizilayMap![2]["arac"],
                        stok[2],
                        getDistanceBetween(
                          _userLat,
                          widget.dbKizilayMap![2]["lat"],
                          _userLng,
                          widget.dbKizilayMap![2]["lng"],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .02,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * .08,
            decoration: const BoxDecoration(
              color: Colors.white, // Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(25, 0, 0, 0),
                  offset: Offset(-1, -2),
                  spreadRadius: .3,
                  blurRadius: 4.2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () =>
                      _getOptimalKizilayIndex(), //Navigator.of(context).pop(),
                  child: Text(
                    "Geri",
                    style: GoogleFonts.robotoMono(
                      fontSize: MediaQuery.of(context).size.width * .038,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _currentUser =
                        Provider.of<AppStateManager>(context, listen: false)
                            .getCurrentUserID;
                    _currentUserName =
                        Provider.of<AppStateManager>(context, listen: false)
                            .getCurrentUserName;
                    _currentUserLat =
                        Provider.of<AppStateManager>(context, listen: false)
                            .getCurrentUserLat;
                    _currentUserLng =
                        Provider.of<AppStateManager>(context, listen: false)
                            .getCurrentUserLng;

                    //TODO: Saat formatı değişebilir.
                    String dt = DateFormat("HH:mm").format(DateTime.now());
                    setState(() {});
                    optimumIndex = _getOptimalKizilayIndex();
                    print("Yazılacak index : $optimumIndex");
                    // dbTalepMap.addAll({
                    //   "kanGrubu": widget.kanGrubuText,
                    //   "unite": widget.uniteSayisi,
                    //   "talepEdenID": _currentUser,
                    //   "talepEden": _currentUserName,
                    //   "talepEdenLat": _currentUserLat,
                    //   "talepEdenLng": _currentUserLng,
                    //   "kizilay": widget.dbKizilayMap![1]["name"],
                    //   "kizilayID": widget.dbKizilayMap![1]["id"],
                    //   "kizilayLat": widget.dbKizilayMap![1]["lat"],
                    //   "kizilayLng": widget.dbKizilayMap![1]["lng"],
                    //   "durum": "iletildi",
                    //   "id": "",
                    //   "olusturmaSaati": dt,
                    //   "kalkisSaati": "",
                    // });
                    // await taleplerRef.add(dbTalepMap).then((value) {
                    //   taleplerRef.doc(value.id).update({"id": value.id});
                    // });
                    // Navigator.of(context).pop();
                  },
                  child: Text(
                    "Onaylıyorum",
                    style: GoogleFonts.robotoMono(
                      fontSize: MediaQuery.of(context).size.width * .034,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: projectRed,
                  ),
                ),
                // SizedBox(
                //   width: MediaQuery.of(context).size.width * .05,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _iletildiMesajContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * .066),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Color.fromARGB(150, 128, 214, 218),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(25, 0, 0, 0),
            offset: Offset(1, 2),
            spreadRadius: .3,
            blurRadius: 4.2,
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width * .6,
      height: MediaQuery.of(context).size.height * .1,
      child: Center(
        child: Text(
          _otomatikYazisi,
          style: GoogleFonts.robotoMono(
            fontSize: MediaQuery.of(context).size.width * .028,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Container _detayContainer(BuildContext context, name, arac, stok, distance) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(25, 0, 0, 0),
            offset: Offset(1, 2),
            spreadRadius: .3,
            blurRadius: 4.2,
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width * .8,
      height: MediaQuery.of(context).size.height * .18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: projectRed,
              borderRadius: BorderRadius.circular(8),
            ),
            width: MediaQuery.of(context).size.width * .34,
            height: MediaQuery.of(context).size.height * .04,
            child: Center(
              child: Text(
                name,
                style: GoogleFonts.robotoMono(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * .03,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Stok : ",
                    style: GoogleFonts.robotoMono(
                      fontSize: MediaQuery.of(context).size.width * .036,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    stok,
                    style: GoogleFonts.robotoMono(
                      color: projectRed,
                      fontSize: MediaQuery.of(context).size.width * .036,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Müsait Araç : ",
                    style: GoogleFonts.robotoMono(
                      fontSize: MediaQuery.of(context).size.width * .036,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    arac,
                    style: GoogleFonts.robotoMono(
                      color: projectRed,
                      fontSize: MediaQuery.of(context).size.width * .036,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Uzaklık : ",
                style: GoogleFonts.robotoMono(
                  fontSize: MediaQuery.of(context).size.width * .036,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "$distance km",
                style: GoogleFonts.robotoMono(
                  color: projectRed,
                  fontSize: MediaQuery.of(context).size.width * .036,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kanGrubuVeUniteRow(String headingText, String dataText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          headingText,
          style: GoogleFonts.robotoMono(
            fontSize: MediaQuery.of(context).size.width * .042,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * .12,
          height: MediaQuery.of(context).size.height * .06,
          decoration: BoxDecoration(
            color: projectRed,
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
                dataText,
                style: GoogleFonts.robotoMono(
                  fontSize: MediaQuery.of(context).size.width * .050,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

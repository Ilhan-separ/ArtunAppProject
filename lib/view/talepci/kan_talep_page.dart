import 'package:artun_flutter_project/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class KanTalepScreen extends StatefulWidget {
  const KanTalepScreen({super.key});

  @override
  State<KanTalepScreen> createState() => KanTalepScreenState();
}

class KanTalepScreenState extends State<KanTalepScreen> {
  final db = FirebaseFirestore.instance.collection("Talepler");
  final dbTalepMap = <String, String?>{};

  final String _kanGrubu = "Kan Grubunu Seçiniz:";
  final String _kanUnitesi = "Kaç Ünite Olacağını Şeçiniz:";
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

  String? _selectedKanTipi = "A+";
  String? _selectedUniteSayisi = '1';

  Widget customSizedBox(Widget child) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .23,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _kanGrubu,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                customSizedBox(
                  DropdownButtonFormField<String>(
                    style: TextStyle(fontSize: 20, color: projectOrange),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              width: .1,
                            ))),
                    value: _selectedKanTipi,
                    items: _kanGrubuListesi
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedKanTipi = value;
                    }),
                  ),
                ),
              ],
            ),
            Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _kanUnitesi,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                customSizedBox(
                  DropdownButtonFormField<String>(
                    style: TextStyle(fontSize: 20, color: projectOrange),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              width: .1,
                            ))),
                    value: _selectedUniteSayisi,
                    items: _uniteSayiListesi
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedUniteSayisi = value;
                    }),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 35,
            ),
            ElevatedButton(
              onPressed: () async => _showKanTalepDialog(context),
              child: Text("Talepte Bulun"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showKanTalepDialog(BuildContext context) {
    //Dialog'u burdan gösterip tüm işlemlerini burdan yapıyorum.
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("Seçilenler:"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text("Seçilen Kan Grubu : $_selectedKanTipi"),
                Text("Seçilen Ünite : $_selectedUniteSayisi ")
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Geri",
                style: TextStyle(
                  color: Colors.blueGrey[400],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                dbTalepMap.addAll({
                  "kanGrubu": _selectedKanTipi,
                  "unite": _selectedUniteSayisi,
                });
                db
                    .add(dbTalepMap)
                    .then((value) => print("id is : ${value.id}"));
                Navigator.of(context).pop();
              },
              child: Text(
                "Talep Et",
                style: TextStyle(
                    color: Colors.blueGrey[700], fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

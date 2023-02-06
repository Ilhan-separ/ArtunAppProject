import 'package:artun_flutter_project/utilities/app_state_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'dart:math' as math;
import '../constants.dart';

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic>? userSpesicifTalepList;
  final double kizilayLat;
  final double talepciLat;
  final double kizilayLng;
  final double talepciLng;

  const DetailsPage({
    super.key,
    required this.userSpesicifTalepList,
    required this.kizilayLat,
    required this.talepciLat,
    required this.kizilayLng,
    required this.talepciLng,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Uzaklık Hesaplaması
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

  // Hastane1 : 39.41700566935059, 29.991500337367963 k
  // Hastane2 : 39.42479813980154, 29.963830453666546 k
  // Hastane3 : 39.39500424002382, 30.028720089218048 k

  // Belediye : 39.426029005852996, 29.98956132990584 k
  // Kütahya Kalesi : 39.419384182446386, 29.970091345344922 k
  // Hazer Dinari : 39.395094507654825, 30.033696096436383 k

  late LatLng _kizilay;
  late LatLng _hastane;

  List<LatLng> polyLineCoordinates = [];

  void getPolyPoints() async {
    //TODO: Real time tracking yapılacak.
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(_kizilay.latitude, _kizilay.longitude),
        PointLatLng(_hastane.latitude, _hastane.longitude));

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) =>
            polyLineCoordinates.add(LatLng(point.latitude, point.longitude)),
      );
      setState(() {});
    }
  }

  // void getCurrentLocation() {} Burdan mevcut lokasyonu çekebilirim.

  Set<Marker> setMarkers() {
    _kizilay = LatLng(widget.kizilayLat, widget.kizilayLng);
    _hastane = LatLng(widget.talepciLat, widget.talepciLng);
    return {
      Marker(
          markerId: MarkerId("kizilay"),
          position: LatLng(widget.kizilayLat, widget.kizilayLng)),
      Marker(
          markerId: MarkerId("hastane"),
          position: LatLng(widget.talepciLat, widget.talepciLng)),
    };
  }

  Set<Marker> _markers = {};
  String _currentUserId = "";
  String _droneDurum = "Hazırlanıyor";

  @override
  void initState() {
    _markers = setMarkers();
    getPolyPoints();
    switch (widget.userSpesicifTalepList!["durum"]) {
      case "iletildi":
        _droneDurum = "Hazırlanıyor";
        break;
      case "yolda":
        _droneDurum = "Yolda";
        break;
      case "vardı":
        _droneDurum = "Vardı";
        break;
      default:
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentUserId = Provider.of<AppStateManager>(context).getCurrentUserID;
  }

  bool _isBackClicked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Talep Detayları",
          style: TextStyle(color: Colors.white),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: projectRed,
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              if (!_isBackClicked) {
                setState(() {
                  _isBackClicked = !_isBackClicked;
                });
                Navigator.of(context).pop();
              } else {
                null;
              }
            }),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.50,
                  width: MediaQuery.of(context).size.width,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.52,
                  child: ClipRRect(
                    child: buildGoogleMaps(),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.43,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 6,
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: projectCyan,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: ListView(
                          physics: BouncingScrollPhysics(
                              parent: FixedExtentScrollPhysics()),
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  // Kan Grubu Ve Ünite SAyısı Bilgisi

                                  padding: EdgeInsets.only(left: 24, right: 12),
                                  child: Column(children: [
                                    _kanGrubuVeUniteRow(
                                        "Kan Grubu",
                                        widget.userSpesicifTalepList![
                                            dbDocKanGrubu]),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    _kanGrubuVeUniteRow(
                                        "Ünite",
                                        widget.userSpesicifTalepList![
                                            dbDocKanUnite]),
                                  ]),
                                ),
                                const Divider(
                                  height: 24,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _droneDurumBuilder(context),
                                    Text("Estimated time"),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius:
                                            BorderRadius.circular(24)),
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 12,
                                        top: 10,
                                        bottom: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _kalkisVeVarisBuilder(
                                                "Kalkış", "kalkis"),
                                            Text(
                                              widget.userSpesicifTalepList![
                                                  dbDocKizilay],
                                              style: GoogleFonts.roboto(
                                                textStyle: TextStyle(
                                                  fontSize: 20,
                                                  color: projectRed,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          children: [
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Image.asset(
                                                "assets/ic_boslukluCizgi.png"),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _kalkisVeVarisBuilder(
                                                "Varış", "varis"),
                                            Text(
                                              widget.userSpesicifTalepList![
                                                  dbDocTalepEden],
                                              style: GoogleFonts.roboto(
                                                textStyle: TextStyle(
                                                  fontSize: 20,
                                                  color: projectRed,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(
                                  height: 32,
                                ),
                                ListTile(
                                  title: Text(
                                    'Uzaklık',
                                    style: GoogleFonts.roboto(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  dense: true,
                                  subtitle: Text(
                                    "${getDistanceBetween(_kizilay.latitude, _hastane.latitude, _kizilay.longitude, _hastane.longitude)} km",
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600]),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Talebin Oluşturulma Saati",
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        widget.userSpesicifTalepList![
                                            dbDocOlusturulmaSaati],
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 8, left: 8, right: 8),
                      child: _currentUserId ==
                              widget.userSpesicifTalepList!["kizilayID"]
                          ? _kizilayElevatedButtonControl()
                          : ElevatedButton(
                              onPressed: () async =>
                                  widget.userSpesicifTalepList!["durum"] !=
                                          "yolda"
                                      ? null
                                      : _showHastaneOnayDialog(context),
                              child: Center(
                                child: _droneDurum == "Yolda"
                                    ? Text("Paketi Aldım")
                                    : Icon(Icons.clear),
                              ),
                            ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _kizilayElevatedButtonControl() {
    return ElevatedButton(
      onPressed: () async {
        String dt = DateFormat("HH:mm").format(DateTime.now());
        widget.userSpesicifTalepList![dbDocDroneDurum] == "iletildi"
            ? {
                await FirebaseFirestore.instance
                    .collection("Talepler")
                    .doc(widget.userSpesicifTalepList!["id"])
                    .update({dbDocDroneDurum: "yolda", dbDocKalkisSaati: dt}),
                setState(() {
                  _droneDurum = "Yolda";
                }),
              }
            : null;
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: projectCyan,
      ),
      child: Center(
        child: _droneDurum == "Hazırlanıyor"
            ? Text("Yola Çık")
            : Icon(Icons.clear),
      ),
    );
  }

  Future<void> _showHastaneOnayDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Paketinizi aldığınızı onaylıyor musunuz?"),
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
            onPressed: () async {
              //TODO: Dronun varmış olma durmunu drondan gelen veriler ile algılayacağım.

              await FirebaseFirestore.instance
                  .collection("Talepler")
                  .doc(widget.userSpesicifTalepList!["id"])
                  .update({dbDocDroneDurum: "vardı"});

              setState(() {
                _droneDurum = "Vardı";
              });
              Navigator.of(context).pop();
            },
            child: Text(
              "Onaylıyorum",
              style: TextStyle(color: projectCyan, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kalkisVeVarisBuilder(String headingText, String icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset("assets/ic_$icon.png"),
        const SizedBox(
          width: 8,
        ),
        Text(
          headingText,
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _droneDurumBuilder(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Color.fromARGB(60, 220, 198, 198),
          borderRadius: BorderRadius.circular(24)),
      constraints: BoxConstraints.tightFor(
          width: MediaQuery.of(context).size.width * .52, height: 65),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Dronun Mevcut Durumu",
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: 14,
                  color: projectRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              _droneDurum,
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kanGrubuVeUniteRow(String headingText, String dataText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          headingText,
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: 50,
          height: 40,
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
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  GoogleMap buildGoogleMaps() {
    return GoogleMap(
        mapType: MapType.normal,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          )
        },
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _hastane,
          zoom: 14,
        ),
        zoomControlsEnabled: false,
        polylines: {
          Polyline(
            polylineId: PolylineId("yol"),
            visible: true,
            zIndex: 1,
            points: [_kizilay, _hastane],
            color: Colors.purpleAccent,
            width: 3,
          ),
        },
        markers: _markers);
  }
}

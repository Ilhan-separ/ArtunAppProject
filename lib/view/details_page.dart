import 'dart:async';

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
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:ui' as ui;
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

  DatabaseReference estimatedTimeRef =
      FirebaseDatabase.instance.ref("Delivery/estimated_delivery_time");
  DatabaseReference durumRef = FirebaseDatabase.instance.ref("Delivery/durum");

  DatabaseReference isDeliveredRef = FirebaseDatabase.instance.ref("Delivery/");
  DatabaseReference hastaneLocRef =
      FirebaseDatabase.instance.ref("HospitalLocation/");
  DatabaseReference liveLocationLatRef =
      FirebaseDatabase.instance.ref("Live/live_location_lat");
  DatabaseReference liveLocationLngRef =
      FirebaseDatabase.instance.ref("Live/live_location_long");

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

  var _currentLocation;

  List<LatLng> polyLineCoordinates = [];

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(widget.kizilayLat, widget.kizilayLng),
        PointLatLng(widget.talepciLat, widget.talepciLng));

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) =>
            polyLineCoordinates.add(LatLng(point.latitude, point.longitude)),
      );
      setState(() {});
    }
  }

  Future<Uint8List> getBytesFromAsset(
      {required String path, required int width}) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  BitmapDescriptor hastaneIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor kizilayIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  Future<Uint8List> setCustomMarkerIcon(path, width) async {
    return await getBytesFromAsset(
        path:
            path, //"assets/ic_hastane_marker.png", //paste the custom image path
        width: width // size of custom image as marker
        );
    // final Uint8List kizilayMarker = await getBytesFromAsset(
    //     path: "assets/ic_kizilay_marker.png", //paste the custom image path
    //     width: 60 // size of custom image as marker
    //     );
    // final Uint8List droneMarker = await getBytesFromAsset(
    //     path: "assets/ic_drone.png", //paste the custom image path
    //     width: 100 // size of custom image as marker
    //     );
  }

  final Set<Marker> _markers = {};
  String _currentUserId = "";
  String _droneDurum = "-";
  String _estimatedTime = "-";

  num _liveLat = -35.36257681520932;
  num _liveLng = 149.1652430341935;

  @override
  void initState() {
    setDbCurrentValues();
    getPolyPoints();
    setMarkers();
    //_markers = setMarkers();
    super.initState();
  }

  Future<void> setMarkers() async {
    _markers.add(
      Marker(
        markerId: MarkerId("kizilay"),
        icon: BitmapDescriptor.fromBytes(
            await setCustomMarkerIcon("assets/ic_hastane_marker.png", 60)),
        position: LatLng(widget.kizilayLat, widget.kizilayLng),
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId("hastane"),
        icon: BitmapDescriptor.fromBytes(
            await setCustomMarkerIcon("assets/ic_kizilay_marker.png", 60)),
        position: LatLng(widget.talepciLat, widget.talepciLng),
      ),
    );
    _markers.add(Marker(
        markerId: MarkerId("currentLoc"),
        icon: BitmapDescriptor.fromBytes(
            await setCustomMarkerIcon("assets/ic_drone.png", 100)),
        position: LatLng(-35.36250808785522, 149.1650383646676)));
  }

  late Stream<DocumentSnapshot<Map<String, dynamic>>> myStream;

  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      durumSubscription;
  late StreamSubscription<DatabaseEvent> liveLatListen;
  late StreamSubscription<DatabaseEvent> liveLngListen;
  late StreamSubscription<DatabaseEvent> estimatedListen;

  Future<void> setDbCurrentValues() async {
    myStream = FirebaseFirestore.instance
        .collection("Talepler")
        .doc(widget.userSpesicifTalepList!["id"])
        .snapshots();

    liveLatListen = liveLocationLatRef.onValue.listen(
      (event) {
        final data = event.snapshot.value;
        if (mounted) {
          setState(() {
            _liveLat = data as num;
            //print(" data Lat : $_liveLat");
          });
        }
      },
    );

    liveLngListen = liveLocationLngRef.onValue.listen(
      (event) {
        final data = event.snapshot.value;
        if (mounted) {
          setState(() {
            _liveLng = data as num;
            //print(" data Lng : $_liveLng");
          });
        }
      },
    );
    estimatedListen = estimatedTimeRef.onValue.listen(
      (event) {
        final data = event.snapshot.value;
        if (mounted) {
          setState(() {
            _estimatedTime = data as String;
          });
        }
        //print(" estimated Time :  $data");
      },
    );

    durumSubscription = myStream.listen((event) {
      if (event.exists) {
        if (event.data() == null) {
          durumSubscription.cancel();
        }

        final data = event.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _droneDurum = data["durum"];
          });
        }
        //print("drone Durum : $_droneDurum");
      }
    });

    var droneMarker = BitmapDescriptor.fromBytes(
        await setCustomMarkerIcon("assets/ic_drone.png", 100));

    if (mounted) {
      setState(() {
        _markers.removeWhere((m) => m.markerId.value == "currentLoc");
        _markers.add(
          Marker(
            markerId: MarkerId("currentLoc"),
            icon: droneMarker,
            position: LatLng(_liveLat.toDouble(), _liveLng.toDouble()),
          ),
        );
        //print("LooooooooooooooooooooooooooooooooASDASFZXCAS ${LatLng(_liveLat.toDouble(), _liveLng.toDouble())}");
      });
    }

    // mapController?.animateCamera(
    //   CameraUpdate.newCameraPosition(
    //     CameraPosition(zoom: 18.8, target: LatLng(_liveLat, _liveLng)),
    //   ),
    // );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _currentUserId = Provider.of<AppStateManager>(context).getCurrentUserID;
  }

  @override
  void dispose() {
    durumSubscription.cancel();
    liveLatListen.cancel();
    liveLngListen.cancel();
    estimatedListen.cancel();
    mapController!.dispose();
    super.dispose();
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
      body: FutureBuilder(
        future: setDbCurrentValues(),
        builder: (context, snapshot) => SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Stack(
                children: [
                  // SizedBox(
                  //   height: MediaQuery.of(context).size.height * 0.50,
                  //   width: MediaQuery.of(context).size.width,
                  // ),
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
                                    // Kan Grubu Ve Ünite Sayısı Bilgisi

                                    padding:
                                        EdgeInsets.only(left: 24, right: 12),
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
                                      _droneDurumContainer(context),
                                      _estimatedTimeContainer(context),
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
                                      "${getDistanceBetween(
                                        widget.talepciLat,
                                        widget.kizilayLat,
                                        widget.talepciLng,
                                        widget.kizilayLng,
                                      )} km",
                                      style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600]),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                            ? _kizilayElevatedButtonControl(context)
                            : _hastaneElevatedButtonControl(context),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _estimatedTimeContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: projectCyan.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24)),
      constraints: BoxConstraints.tightFor(
        width: MediaQuery.of(context).size.width * .30,
        height: MediaQuery.of(context).size.height * .09,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Tahmini Varış",
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: 14,
                  color: projectRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              _estimatedTime.toString(),
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

  ElevatedButton _hastaneElevatedButtonControl(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: projectCyan,
      ),
      onPressed: _droneDurum != "yolda"
          ? null
          : () async => _showHastaneOnayDialog(context),
      child: Center(child: Text("Paketi Aldım")),
    );
  }

  ElevatedButton _kizilayElevatedButtonControl(context) {
    return ElevatedButton(
      onPressed: _droneDurum == "iletildi"
          ? () async {
              String dt = DateFormat("HH:mm").format(DateTime.now());
              _showKizilayOnayDialog(dt, context);
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: projectCyan,
      ),
      child: Center(
        child: Text("Yola Çık"),
      ),
    );
  }

  Future<dynamic> _showKizilayOnayDialog(String dt, context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Dronun yola çıkmasını onaylıyor musunuz?"),
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
                  .update({dbDocDroneDurum: "yolda", dbDocKalkisSaati: dt});
              await hastaneLocRef.set({
                "hospitalLocation_lat": widget.talepciLat,
                "hospitalLocation_long": widget.talepciLng,
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

              await isDeliveredRef.update({
                "isDelivered": true,
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

  Widget _droneDurumContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Color.fromARGB(60, 220, 198, 198),
          borderRadius: BorderRadius.circular(24)),
      constraints: BoxConstraints.tightFor(
        width: MediaQuery.of(context).size.width * .52,
        height: MediaQuery.of(context).size.height * .09,
      ),
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
              _droneDurum.toUpperCase(),
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
          target: LatLng(widget.kizilayLat, widget.kizilayLng),
          zoom: 17.8,
          tilt: 50,
          bearing: 30,
        ),
        zoomControlsEnabled: false,
        polylines: {
          Polyline(
            polylineId: PolylineId("yol"),
            visible: true,
            zIndex: 1,
            points: [
              LatLng(widget.kizilayLat, widget.kizilayLng),
              LatLng(widget.talepciLat, widget.talepciLng)
            ],
            color: projectCyan,
            width: 3,
          ),
        },
        markers: _markers);
  }
}

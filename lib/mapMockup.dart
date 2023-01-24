import 'dart:async';

import 'package:artun_flutter_project/utilities/app_state_maneger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'dart:math' as math;
import '../constants.dart';

class MapMockupPage extends StatefulWidget {
  const MapMockupPage({super.key});

  @override
  State<MapMockupPage> createState() => _MapMockupPageState();
}

class _MapMockupPageState extends State<MapMockupPage>
    with TickerProviderStateMixin {
  Animation<double>? _animation;
  GoogleMapController? mapController;

  final _mapMarkerSC = StreamController<List<Marker>>();
  var tickerOver = false;

  StreamSink<List<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;

  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  animateCurrentLocationMarker(
    double fromLat, //Starting latitude
    double fromLong, //Starting longitude
    double toLat, //Ending latitude
    double toLong, //Ending longitude
    StreamSink<List<Marker>> mapMarkerSink,
    TickerProvider
        provider, //Ticker provider of the widget. This is used for animation
    GoogleMapController? controller, //Google map controller of our widget
  ) async {
    var currentMarker = Marker(
      markerId: const MarkerId("currentMarker"),
      position: LatLng(fromLat, fromLong),
    );
    _markers.add(currentMarker);
    mapMarkerSink.add(_markers);

    final animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: provider,
    );

    Tween<double> tween = Tween(begin: 0, end: 1);

    _animation = tween.animate(animationController)
      ..addListener(() async {
        final v = _animation!.value;
        double lng = v * toLong + (1 - v) * fromLong;
        double lat = v * toLat + (1 - v) * fromLat;
        LatLng newPos = LatLng(lat, lng);
        if (_markers.contains(currentMarker)) _markers.remove(currentMarker);

        currentMarker = Marker(
          markerId: const MarkerId("onTheWay"),
          position: newPos,
        );

        _markers.add(currentMarker);
        mapMarkerSink.add(_markers);
      });

    animationController.forward();
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

  final LatLng _vazo = const LatLng(39.419589, 29.985422);
  LatLng _evim = const LatLng(39.438231, 29.981233);

  List<LatLng> polyLineCoordinates = [];

  void getPolyPoints() async {
    //TODO: Real time tracking yapılacak.
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(_vazo.latitude, _vazo.longitude),
        PointLatLng(_evim.latitude, _evim.longitude));

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) =>
            polyLineCoordinates.add(LatLng(point.latitude, point.longitude)),
      );
      setState(() {});
    }
  }

  void onAddMarker(LatLng latLng) {
    setState(() {
      _markers.add(Marker(markerId: MarkerId("evim"), position: latLng));
      _evim = latLng;
      getPolyPoints();
    });
  }

  void getCurrentLocation() {}

  final List<Marker> _markers = [
    const Marker(
        markerId: MarkerId("vazo"), position: LatLng(39.419589, 29.985422)),
    const Marker(
        markerId: MarkerId("evim"), position: LatLng(39.438231, 29.981233)),
  ];

  @override
  void initState() {
    getPolyPoints();

    Future.delayed(const Duration(seconds: 1)).then((value) {
      animateCurrentLocationMarker(_evim.latitude, _evim.longitude,
          _vazo.latitude, _vazo.longitude, _mapMarkerSink, this, mapController);
      LogoutClickable();
    });

    super.initState();
  }

  void LogoutClickable() async {
    // Logout butonunu tıklanabilir zamanını ayarlar
    Duration time = Duration(seconds: 20);

    Future.delayed(time, (() {
      setState(() {
        tickerOver = true;
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    final googleMap = StreamBuilder<List<Marker>>(
      stream: mapMarkerStream,
      builder: (context, snapshot) {
        return GoogleMap(
          mapType: MapType.normal,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            )
          },
          onTap: ((LatLng) {
            _markers.remove(const MarkerId("evim"));
            onAddMarker(LatLng);
          }),
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _evim,
            zoom: 13.5,
          ),
          polylines: {
            Polyline(
              polylineId: PolylineId("yol"),
              visible: true,
              zIndex: 1,
              points: [_vazo, _evim],
              color: Colors.purpleAccent,
              width: 3,
            ),
          },
          markers: Set<Marker>.of(snapshot.data ?? []),
        );
      },
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: googleMap,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'Distance : ${getDistanceBetween(_vazo.latitude, _evim.latitude, _vazo.longitude, _evim.longitude)} km',
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(
                  height: 16,
                ),
                Text("Detaylar da detaylar babam"),
                Text("Talep Eden Yer"),
                Text("Talep Edilen Detayları"),
                Text("Estimated time maybe dk"),
                SizedBox(
                  height: 16,
                ),
                Visibility(
                  visible: tickerOver,
                  child: ElevatedButton(
                      child: Text("Logout"),
                      onPressed: () async {
                        Provider.of<AppStateManager>(context, listen: false)
                            .logout();
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

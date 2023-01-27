import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'dart:math' as math;
import '../constants.dart';
import '../utilities/app_state_manager.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

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

  final Set<Marker> _markers = {
    const Marker(
        markerId: MarkerId("vazo"), position: LatLng(39.419589, 29.985422)),
    const Marker(
        markerId: MarkerId("evim"), position: LatLng(39.438231, 29.981233)),
  };

  @override
  void initState() {
    getPolyPoints();
    super.initState();
  }

  var _isBackClicked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Detaylar",
          style: TextStyle(color: Colors.black),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              if (!_isBackClicked) {
                setState(() {
                  _isBackClicked = !_isBackClicked;
                });
                Navigator.of(context).pop();
              }
            }),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: Colors.black,
            ),
            color: Colors.black,
            onPressed: () {
              Provider.of<AppStateManager>(context, listen: false).logout();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: buildGoogleMaps(),
                  ),
                ),
                SizedBox(
                  height: 16,
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
              ],
            ),
          ),
        ),
      ),
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
        onTap: ((LatLng) {
          _markers.remove(const MarkerId("evim"));
          onAddMarker(LatLng);
        }),
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _evim,
          zoom: 14,
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
        markers: _markers);
  }
}

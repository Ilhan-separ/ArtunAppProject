import 'package:artun_flutter_project/pages/Khome_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:math' as math;
import 'constants.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

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

  final Set<Marker> _markers = {
    const Marker(
        markerId: MarkerId("vazo"), position: LatLng(39.419589, 29.985422)),
    const Marker(
        markerId: MarkerId("evim"), position: LatLng(39.438231, 29.981233)),
  };

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

  @override
  void initState() {
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Artun Maps"),
        backgroundColor: Colors.blue[700],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              child: GoogleMap(
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
                    zoom: 15,
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
                  markers: _markers),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
                'Distance : ${getDistanceBetween(_vazo.latitude, _evim.latitude, _vazo.longitude, _evim.longitude)} km'),
            TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return KhomePage();
                  }));
                },
                child: Text("to home page"))
          ],
        ),
      ),
    );
  }
}

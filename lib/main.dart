// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';
import 'package:flutter_map/network.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};

  //Add Current Location
  LocationData? currentLocation;
  Location? location;
  StreamSubscription<LocationData>? locationSubscription;
  //Add route
  final Set<Polyline> polyLines = {};
  final List<LatLng> polyPoints = [];

  //Add Current Loaction
  void updateCurrentLocationPin() async {
    dynamic drivingIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'images/driving_pin.png');
    setState(() {
      var pinPosition = LatLng(currentLocation!.latitude ?? 0.00,
          currentLocation!.longitude ?? 0.00);

      markers.removeWhere((m) => m.markerId.value == 'currentLacationPin');
      markers.add(Marker(
        markerId: const MarkerId('currentLacationPin'),
        position: pinPosition,
        icon: drivingIcon,
        infoWindow: const InfoWindow(
            title: "Current Location", snippet: "I am here now!"),
      ));
      addRoute();
    });
  }

  @override
  void initState() {
    location = Location();
    locationSubscription =
        location!.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      updateCurrentLocationPin();
    });
    Marker sciMarker = Marker(
        markerId: const MarkerId("SciTech"),
        position: const LatLng(7.166845701327935, 100.61445293569375),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
            title: "Science and Technology Faculty",
            onTap: () {
              launchUrl(Uri.parse("https://sci.skru.ac.th"));
            }));
    Marker homeMarker = Marker(
        markerId: const MarkerId("Home"),
        position: const LatLng(7.174796280128467, 100.61304593931796),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
        infoWindow: InfoWindow(
          title: "Home",
        ));
    markers.add(sciMarker);
    markers.add(homeMarker);

    super.initState();
  }

  static final CameraPosition _kHome = CameraPosition(
    target: LatLng(6.569812500966146, 101.29590864267702),
    zoom: 17.4746,
  );

  static final CameraPosition _kSci = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(7.166902574420149, 100.61447650730884),
      tilt: 40.440717697143555,
      zoom: 16.151926040649414);

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_new
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: markers,
        polylines: polyLines,
        initialCameraPosition: _kHome,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheScibuilding,
        label: Text('To the Science building!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheScibuilding() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kSci));
  }

  //Add route
  setPolyLines() {
    Polyline polyline = Polyline(
      polylineId: const PolylineId("polyline"),
      color: Colors.lightBlue,
      width: 5,
      points: polyPoints,
    );
    polyLines.add(polyline);
    setState(() {});
  }

  void addRoute() async {
    polyPoints.clear();
    NetworkHelper network = NetworkHelper(
      101.29591420429735,
      6.569812500966146,
      100.61447650730884,
      7.166902574420149,
    );

    try {
      dynamic data = await network.getData();

      List<dynamic> ls = data['features'][0]['geometry']['coordinates'];

      for (int i = 0; i < ls.length; i++) {
        polyPoints.add(LatLng(ls[i][1], ls[i][0]));
      }
      setPolyLines();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController googleMapController;

  // var lat = 37.15478;
  // var lon = -122.78945;
  Set<Marker> markers = {};
  static const CameraPosition initialPosition =
      CameraPosition(target: LatLng(37.15478, -122.78945), zoom: 20.0);
  // static const CameraPosition targetPosition =
  //     CameraPosition(target: LatLng(38.15478, -167.22876), zoom: 14.0);

  var location = '';
  String? latitude;
  String? longitude;
  void getLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    setState(() {
      location = "Latitude: $latitude and Longitude: $longitude";
    });
  }

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  void googleMap() async {
    final Uri googleUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");
    if (!await launchUrl(googleUrl)) throw 'Could not launch $googleUrl';
  }

  Future<Position> currentPosition() async {
    var currentPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return currentPos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('location App'),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                onPressed: () {
                  getLocation();
                },
                child: const Text("Get Location"),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text("User Location"),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                location,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () {
                    googleMap();
                  },
                  child: const Text('View in Maps')),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    Position currentPos = await currentPosition();
                    googleMapController.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                            target: LatLng(
                                currentPos.latitude, currentPos.longitude),
                            zoom: 14)));
                    markers.clear();
                    markers.add(Marker(
                        markerId: const MarkerId('currentLocation'),
                        position:
                            LatLng(currentPos.latitude, currentPos.longitude)));
                    setState(() {});
                  },
                  child: const Text('Go to Location')),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                flex: 1,
                child: GoogleMap(
                  initialCameraPosition: initialPosition,
                  markers: markers,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                  },
                ),
              )
            ],
          ),
        ));
  }
}

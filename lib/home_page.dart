import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String locationMessage = 'Current location of the user';
  late String lat;
  late String long;

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request current location');
    }

    return await Geolocator.getCurrentPosition();
  }

  void liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high, distanceFilter: 100);

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();

      setState(() {
        locationMessage = 'Latitude: $lat, Longitude: $long';
      });
    });
  }

  Future<void> openMap(String lat, String long) async {
    String googleMapURL =
        'https://www.google.com/maps/search/?api=1&query=$lat,$long';

    await canLaunchUrlString(googleMapURL)
        ? await launchUrlString(googleMapURL)
        : throw 'Could not launch $googleMapURL';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              locationMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  getCurrentLocation().then((value) {
                    lat = '${value.latitude}';
                    long = '${value.longitude}';
                    setState(() {
                      locationMessage = 'Latitude: $lat , Longitude: $long';
                    });

                    liveLocation();
                  });
                },
                child: const Text('Get current location')),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  openMap(lat, long);
                },
                child: const Text('Open Google Map')),
          ],
        ),
      ),
    );
  }
}

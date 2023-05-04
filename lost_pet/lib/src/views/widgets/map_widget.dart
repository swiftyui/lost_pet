import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lost_pet/src/services/theme.dart';
import 'package:permission_handler/permission_handler.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidget();
}

class _MapWidget extends State<MapWidget> {
  late final CameraPosition _usersLocation;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    _asyncInit();
  }

  Future _asyncInit() async {
    await _getCurrentLocation();
  }

  Future _getCurrentLocation() async {
    // request permission for the devices location
    if (await Permission.location.request().isGranted) {
      //get the user's current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _usersLocation = CameraPosition(
        target: LatLng(
          position.latitude,
          position.longitude,
        ),
        zoom: 15,
      );
      setState(() {});
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: lightCardBoxShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Pets near me',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 400,
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _usersLocation,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  buildingsEnabled: true,
                  compassEnabled: false,
                  trafficEnabled: false,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: false,
                  indoorViewEnabled: false,
                  liteModeEnabled: false,
                  scrollGesturesEnabled: true,
                  myLocationEnabled: true,
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  rotateGesturesEnabled: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lost_pet/src/models/user_model.dart';
import 'package:lost_pet/src/services/animation_list.dart';
import 'package:lost_pet/src/services/theme.dart';
import 'package:lost_pet/src/services/user_provider.dart';
import 'package:lost_pet/src/views/home_screens/home_drawer.dart';
import 'package:lost_pet/src/views/lost_pet_screens/report_lost_pet.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  bool _hasLocationAccess = false;
  late final CameraPosition _usersLocation;

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
      _hasLocationAccess = true;
      _usersLocation = CameraPosition(
        target: LatLng(
          position.latitude,
          position.longitude,
        ),
        zoom: 15,
      );
      setState(() {});
    } else {
      _hasLocationAccess = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Lost Pets'),
        actions: [
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
            icon: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: _buildBody(context),
      endDrawer: const HomeDrawer(),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UserProvider.instance,
      builder: (context, value, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              _welcomeWidget(context, value),
              _reportLostPet(context),
              _mapWidget(context),
            ],
          ),
        );
      },
    );
  }

  Widget _reportLostPet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ReportLostPetScreen()));
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: lightCardBoxShadow,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: greenAccentColour,
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                        width: (MediaQuery.of(context).size.width / 2.8),
                        child: AutoSizeText(
                          'Report a Lost Pet',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          maxFontSize: 16,
                          minFontSize: 6,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapWidget(BuildContext context) {
    if (_hasLocationAccess) {
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
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
                    'Access to your location has been denied',
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
                  child: Lottie.asset(AnimationList.map),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _welcomeWidget(BuildContext context, UserModel? userModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
                  'Hi ${userModel?.displayName}!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "Welcome back to the My Pet app, we've missed you!",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

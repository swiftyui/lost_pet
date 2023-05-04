import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as GoogleMaps;
import 'package:image_picker/image_picker.dart';
import 'package:lost_pet/src/services/animation_list.dart';
import 'package:lost_pet/src/services/theme.dart';
import 'package:lost_pet/src/views/widgets/custom_snackbar.dart';
import 'package:lost_pet/src/views/widgets/error_popup.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportLostPetScreen extends StatefulWidget {
  const ReportLostPetScreen({super.key});

  @override
  State<ReportLostPetScreen> createState() => _ReportLostPetScreenState();
}

class _ReportLostPetScreenState extends State<ReportLostPetScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Color _pickerColor = const Color(0xff443a49);
  final List<AnimalType> _animalTypes = [];
  final TextEditingController _lastSeenLocationController =
      TextEditingController();
  List<XFile>? _imageFileList;
  final ImagePicker _picker = ImagePicker();

  late final GoogleMaps.CameraPosition _usersLocation;
  final Completer<GoogleMaps.GoogleMapController> _controller =
      Completer<GoogleMaps.GoogleMapController>();

  @override
  void initState() {
    super.initState();
    _asyncInit();
  }

  Future _asyncInit() async {
    await _buildAnimalTypeList();
    await _getCurrentLocation();
  }

  Future<void> _getAddressFromLatLng(
      {required GoogleMaps.LatLng location}) async {
    await placemarkFromCoordinates(location.latitude, location.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _lastSeenLocationController.text =
            '${place.street} ${place.subLocality}'
            '${place.subAdministrativeArea} ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future _getCurrentLocation() async {
    // request permission for the devices location
    if (await Permission.location.request().isGranted) {
      //get the user's current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _usersLocation = GoogleMaps.CameraPosition(
        target: GoogleMaps.LatLng(
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

  Future<Permission> _getRelevantPhotoPermission() async {
    if (kIsWeb || !Platform.isAndroid) {
      return Permission.photos;
    }
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt <= 32) {
      return Permission.storage;
    } else {
      return Permission.photos;
    }
  }

  Future<bool> _getPermissions() async {
    Permission permission = await _getRelevantPhotoPermission();
    var status = await permission.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }
    var request = await permission.request();
    return request.isGranted || request.isLimited;
  }

  Future<void> _onImageButtonPressed(
      ImageSource source, BuildContext context) async {
    bool hasPermissions = await _getPermissions();
    if (!hasPermissions) {
      _showError(
          'Photo Access Denied',
          'It seems that access to your photos have been denied, '
              'please grant access in your settings to change your profile picture');
      return;
    }
    try {
      final List<XFile?> pickedFiles = await _picker.pickMultiImage();
      for (var i = 0; i < pickedFiles.length; i++) {
        // pickedFiles[i].path;
      }

      //update the DB
      var imagePath = "";
      if (_imageFileList != null) {
        imagePath = _imageFileList![0].path;
        // await _userProvider.updateProfilePicture(filePath: imagePath);
        // await _loadUserDetails();
        // widget.setLoading(false);

        if (context.mounted) {
          CustomSnackBar.showSnackBar(
            context,
            'Success!',
            'Profile image updated!',
            ContentType.success,
          );
        }
      }
    } catch (error) {
      _showError('Profile Picture Error', '$error');
    }
  }

  Future<void> _showError(String title, String message) async {
    await showDialog(
      context: context,
      builder: (context) => ErrorPopup(
        title: title,
        message: message,
      ),
    );
  }

  void changeColor(Color color) {
    setState(() => _pickerColor = color);
  }

  Future _buildAnimalTypeList() async {
    AnimalType animalType = AnimalType(
      name: 'Cat',
      animationUrl: AnimationList.cat,
      selected: false,
    );
    _animalTypes.add(animalType);

    animalType = AnimalType(
      name: 'Dog',
      animationUrl: AnimationList.dog,
      selected: false,
    );
    _animalTypes.add(animalType);

    animalType = AnimalType(
      name: 'Bird',
      animationUrl: AnimationList.bird,
      selected: false,
    );
    _animalTypes.add(animalType);
    setState(() {});
  }

  Future _setAnimalTypeSelected({required AnimalType animalType}) async {
    setState(() {
      if (animalType.selected == true) {
        animalType.selected = false;
      } else {
        for (var i = 0; i < _animalTypes.length; i++) {
          _animalTypes[i].selected = false;
        }
        animalType.selected = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report a Lost Pet"),
        leading: const BackButton(color: Colors.white),
      ),
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: _buildHorizontalPets(context),
        ),
        _buildDetailsBody(context),
      ],
    );
  }

  Widget _buildDetailsBody(BuildContext context) {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondary,
          border: Border.all(
            color: Theme.of(context).colorScheme.background,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 20, 9, 9),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildNameField(context),
                const SizedBox(height: 15),
                _buildLastSeenTextfield(context),
                const SizedBox(height: 15),
                _buildColorPicker(context),
                const SizedBox(height: 15),
                _buildUploadImageButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadImageButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        await _onImageButtonPressed(ImageSource.gallery, context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: lightCardBoxShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: 30,
                  ),
                  const SizedBox(height: 10),
                  AutoSizeText(
                    'Add Images',
                    maxFontSize: 14,
                    minFontSize: 5,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'avenir',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        await showDialog(
          context: context,
          useSafeArea: true,
          builder: (context) {
            return AlertDialog(
              title: const Text('Select a color'),
              content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ColorPicker(
                  pickerColor: _pickerColor,
                  onColorChanged: changeColor,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: lightCardBoxShadow,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.format_paint_rounded,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: 30,
                  ),
                  const SizedBox(height: 10),
                  AutoSizeText(
                    'Pet color',
                    maxFontSize: 14,
                    minFontSize: 5,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'avenir',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _pickerColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: lightCardBoxShadow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastSeenTextfield(BuildContext context) {
    return TextFormField(
      controller: _lastSeenLocationController,
      decoration: InputDecoration(
        prefixIcon: IconButton(
          onPressed: () async {
            await showDialog(
              context: context,
              useSafeArea: true,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Last known location'),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: GoogleMaps.GoogleMap(
                      mapType: GoogleMaps.MapType.normal,
                      initialCameraPosition: _usersLocation,
                      onMapCreated:
                          (GoogleMaps.GoogleMapController controller) {
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
                      onTap: (argument) async {
                        await _getAddressFromLatLng(location: argument);
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(
            Icons.location_on,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.clear,
            color: Colors.grey,
          ),
        ),
        hintText: 'Last seen address',
        labelText: 'Last seen address',
      ),
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {},
    );
  }

  Widget _buildNameField(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.text_fields_outlined,
        ),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.clear,
            color: Colors.grey,
          ),
        ),
        hintText: 'Pet name',
        labelText: 'Pet name',
      ),
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {},
    );
  }

  Widget _buildHorizontalPets(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < _animalTypes.length; i++)
              _buildPetTypeButton(context, _animalTypes[i]),
          ],
        ),
      ),
    );
  }

  Widget _buildPetTypeButton(BuildContext context, AnimalType animalType) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Stack(
        children: [
          Column(
            children: [
              InkWell(
                onTap: () {
                  _setAnimalTypeSelected(animalType: animalType);
                },
                child: Container(
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
                        Lottie.asset(
                          animalType.animationUrl,
                          height: 120,
                          width: 200,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                          child: SizedBox(
                            width: (MediaQuery.of(context).size.width / 2.8),
                            child: AutoSizeText(
                              animalType.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              maxFontSize: 16,
                              minFontSize: 6,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
          animalType.selected
              ? Container(
                  width: 220,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: lightCardBoxShadow,
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

class AnimalType {
  final String name;
  final String animationUrl;
  bool selected;
  GoogleMaps.LatLng? lastKnownLocation;

  AnimalType({
    required this.name,
    required this.animationUrl,
    required this.selected,
    this.lastKnownLocation,
  });
}

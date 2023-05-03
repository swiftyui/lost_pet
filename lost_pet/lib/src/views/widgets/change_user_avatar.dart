import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_pet/src/services/authentication_service.dart';
import 'package:lost_pet/src/views/widgets/error_popup.dart';
import 'package:lost_pet/src/views/widgets/user_avatar.dart';
import 'package:permission_handler/permission_handler.dart';

class ChangeUserAvatar extends StatefulWidget {
  final double size;
  final bool isLoading;
  final Function(bool) setLoading;
  const ChangeUserAvatar({
    super.key,
    required this.size,
    required this.isLoading,
    required this.setLoading,
  });

  @override
  State<ChangeUserAvatar> createState() => _ChangeUserAvatarState();
}

class _ChangeUserAvatarState extends State<ChangeUserAvatar> {
  late UserProvider _userProvider;
  List<XFile>? _imageFileList;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  _loadUserDetails() async {
    _userProvider = UserProvider.instance;
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
    // widget.setLoading(true);
    // bool hasPermissions = await _getPermissions();
    // if (!hasPermissions) {
    //   widget.setLoading(false);
    //   _showError(
    //       'Photo Access Denied',
    //       'It seems that access to your photos have been denied, '
    //           'please grant access in your settings to change your profile picture');
    //   return;
    // }
    // try {
    //   final XFile? pickedFile = await _picker.pickImage(source: source);
    //   setState(() {
    //     _setImageFileListFromFile(pickedFile);
    //   });

    //   //update the DB
    //   var imagePath = "";
    //   if (_imageFileList != null) {
    //     imagePath = _imageFileList![0].path;
    //     await _userProvider.updateUserData(imagePath, null, null);
    //     await _loadUserDetails();
    //     widget.setLoading(false);

    //     if (context.mounted) {
    //       CustomSnackBar.showSnackBar(
    //         context,
    //         'Success!',
    //         'Profile image updated!',
    //         ContentType.success,
    //       );
    //     }
    //   }
    //   widget.setLoading(false);
    // } catch (error) {
    //   widget.setLoading(false);
    //   _showError('Profile Picture Error', '$error');
    // }
  }

  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: widget.isLoading
              ? () {}
              : () {
                  _onImageButtonPressed(ImageSource.gallery, context);
                },
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                UserAvatar(
                  imageUrl: _userProvider.value?.userImage ?? '',
                  size: widget.size,
                  isLoading: widget.isLoading,
                ),
                _buildCameraIcon(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Align _buildCameraIcon(context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.background,
        radius: widget.size / 6.5,
        child: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
          radius: widget.size / 8,
          child: Icon(
            Icons.camera_alt_outlined,
            size: widget.size / 6.5,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
    );
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);

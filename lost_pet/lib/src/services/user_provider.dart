import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:lost_pet/src/models/user_model.dart';
import 'package:mime/mime.dart';

class UserProvider extends ValueNotifier<UserModel?> {
  static late final UserProvider _instance;
  static UserProvider get instance => _instance;
  User? _firebaseUser;
  final FirebaseAuth? _auth;

  UserProvider._internal(this._auth) : super(null) {
    // Firebase auth changes
    _auth?.userChanges().listen((event) {
      _firebaseUser = event;
      updateUserFromFirebaseChange(event);
    });
  }

  static initialise(FirebaseAuth? instance) {
    _instance = UserProvider._internal(instance);
  }

  Future<void> updateUserFromFirebaseChange(User? user) async {
    if (user == null) {
      value = null;
      return;
    }
    value = UserModel.fromFirebaseUser(user);
    if (value?.uid == user.uid) {
      return;
    }
  }

  Future updateProfilePicture({required String filePath}) async {
    // if the user image needs to be updated

    // Save the Image to Firebase Storage
    final path = 'files/userImages/${UserProvider.instance.value?.uid}';
    final file = File(filePath);

    try {
      // if the user has any profile images stored, remove it and upload the latest
      ListResult storedImages =
          await FirebaseStorage.instance.ref().child(path).listAll();
      for (var image in storedImages.items) {
        await image.delete();
      }

      final urlDownload = await _uploadFile(file, path);
      await _firebaseUser!.updatePhotoURL(urlDownload);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future updateEmailAddress({required String emailAddress}) async {
    await _firebaseUser!.updateEmail(emailAddress);
  }

  Future updateDisplayName({required String displayName}) async {
    await _firebaseUser!.updateDisplayName(displayName);
  }

  Future<String> _uploadFile(File file, String directory) async {
    try {
      // get the content type
      final mimeType = lookupMimeType(file.path);
      final metadata = SettableMetadata(
        contentType: mimeType,
        customMetadata: {'picked-file-path': file.path},
      );
      UploadTask uploadTask;
      Reference ref = FirebaseStorage.instance
          .ref()
          .child(directory)
          .child('/${Guid.newGuid}');

      uploadTask = ref.putData(await file.readAsBytes(), metadata);
      return await (await uploadTask).ref.getDownloadURL();
    } catch (error) {
      throw Exception();
    }
  }
}

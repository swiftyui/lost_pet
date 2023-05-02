import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lost_pet/src/models/user_model.dart';

class AuthenticationServiceError extends Error {
  final String message;
  AuthenticationServiceError(this.message);
}

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

  Future<void> updateUserProfilePicture(String photoURL) async {
    if (_firebaseUser == null) {
      throw StateError('The user is not currently logged in.');
    }
    await _firebaseUser!.updatePhotoURL(photoURL);
  }

  // Future<String> _uploadFile(File file, String directory) async {
  //   try {
  //     // get the content type
  //     final mimeType = lookupMimeType(file.path);
  //     final metadata = SettableMetadata(
  //       contentType: mimeType,
  //       customMetadata: {'picked-file-path': file.path},
  //     );
  //     UploadTask uploadTask;
  //     Reference ref = FirebaseStorage.instance
  //         .ref()
  //         .child(directory)
  //         .child('/${Guid.newGuid}');

  //     uploadTask = ref.putData(await file.readAsBytes(), metadata);
  //     return await (await uploadTask).ref.getDownloadURL();
  //   } catch (error) {
  //     throw Exception();
  //   }
  // }
}

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create a user object based on a FirebaseUser object
  UserModel? _userFromFirebaseUser(User? user) {
    if (user == null) {
      return null;
    }
    return UserModel.fromFirebaseUser(user);
  }

  AuthenticationService() {
    if (isUserLoggedIn) {
      // _updateMicrosoftData();
    }
  }

  bool get isUserLoggedIn => _auth.currentUser != null;

  // Register with email address and password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      result.user?.updateDisplayName('Luke Skywalker');
      User? user = result.user;
      return _userFromFirebaseUser(user!);
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      return null;
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "invalid-email":
          {
            throw AuthenticationServiceError(
              "You provided an invalid email address",
            );
          }
        case "user-disabled":
          {
            throw AuthenticationServiceError(
              "Your user has been disabled",
            );
          }
        case "user-not-found":
          {
            throw AuthenticationServiceError(
              "The user details provided does not match any of our records",
            );
          }
        case "wrong-password":
          {
            throw AuthenticationServiceError(
              "The password you provided was incorrect",
            );
          }
      }
    }
  }

  // Sign in anonymously
  Future<UserModel?> signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user!);
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      return null;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      User? user = result.user;
      UserModel? userModel = _userFromFirebaseUser(user);

      return userModel;
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "invalid-email":
          {
            throw AuthenticationServiceError(
              "You provided an invalid email address",
            );
          }
        case "user-disabled":
          {
            throw AuthenticationServiceError(
              "Your user has been disabled",
            );
          }
        case "user-not-found":
          {
            throw AuthenticationServiceError(
              "The user details provided does not match any of our records",
            );
          }
        case "wrong-password":
          {
            throw AuthenticationServiceError(
              "The password you provided was incorrect",
            );
          }
        case "network-request-failed":
          {
            throw AuthenticationServiceError(
              "Could not connect to the network",
            );
          }
      }
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      if (kDebugMode) {
        print('Logout Error: ${error.toString()}');
      }
    }
  }
}

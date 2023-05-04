import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class UserModel {
  final String uid;
  final String emailAddress;
  final String displayName;
  final String? userImage;

  UserModel({
    required this.uid,
    required this.emailAddress,
    required this.displayName,
    required this.userImage,
  });

  UserModel.fromFirebaseUser(fb_auth.User firebaseUser)
      : uid = firebaseUser.uid,
        emailAddress = firebaseUser.email ?? 'luke@skywalker.com',
        displayName = firebaseUser.displayName ?? 'Luke Skywalker',
        userImage = firebaseUser.photoURL;

  UserModel copyWith({
    String? uid,
    String? emailAddress,
    String? displayName,
    String? userImage,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      emailAddress: emailAddress ?? this.emailAddress,
      displayName: displayName ?? this.displayName,
      userImage: userImage ?? this.userImage,
    );
  }
}

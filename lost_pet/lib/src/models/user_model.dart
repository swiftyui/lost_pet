import 'package:cloud_firestore/cloud_firestore.dart';
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

class UserData {
  final bool? isAdmin;
  final bool? workEmailLinked;
  final String? workEmailAddress;
  final String? personalEmailAddress;
  final String? jobTitle;

  UserData({
    this.isAdmin,
    this.workEmailLinked,
    this.workEmailAddress,
    this.personalEmailAddress,
    this.jobTitle,
  });

  factory UserData.fromFirestore(
    Map<String, dynamic> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot;
    return data.isEmpty
        ? UserData(
            isAdmin: false,
            workEmailLinked: false,
            workEmailAddress: null,
            personalEmailAddress: null,
            jobTitle: null,
          )
        : UserData(
            isAdmin: data['isAdmin'],
            workEmailLinked: data['workEmailLinked'],
            workEmailAddress: data['workEmailAddress'],
            personalEmailAddress: data['personalEmailAddress'],
            jobTitle: data['personalEmailAddress'],
          );
  }

  UserData.fromDocumentSnapshot(DocumentSnapshot doc)
      : isAdmin = doc.data().toString().contains('isAdmin')
            ? doc.get('isAdmin')
            : false,
        workEmailLinked = doc.data().toString().contains('workEmailLinked')
            ? doc.get('workEmailLinked')
            : false,
        workEmailAddress = doc.data().toString().contains('workEmailAddress')
            ? doc.get('workEmailAddress')
            : '',
        personalEmailAddress =
            doc.data().toString().contains('personalEmailAddress')
                ? doc.get('personalEmailAddress')
                : '',
        jobTitle = doc.data().toString().contains('jobTitle')
            ? doc.get('jobTitle')
            : '';

  UserData.fromJson(
    Map<String, dynamic> jsonData,
  )   : isAdmin = jsonData.containsKey("isAdmin") ? jsonData["isAdmin"] : false,
        workEmailLinked = jsonData.containsKey("workEmailLinked")
            ? jsonData["workEmailLinked"]
            : false,
        workEmailAddress = jsonData.containsKey("workEmailAddress")
            ? jsonData["workEmailAddress"]
            : null,
        personalEmailAddress = jsonData.containsKey("personalEmailAddress")
            ? jsonData["personalEmailAddress"]
            : null,
        jobTitle =
            jsonData.containsKey("jobTitle") ? jsonData["jobTitle"] : null;

  Map<String, dynamic> toFirestore() {
    return {
      if (isAdmin != null) "isAdmin": isAdmin,
      if (workEmailLinked != null) "workEmailLinked": workEmailLinked,
      if (workEmailAddress != null) "workEmailAddress": workEmailAddress,
      if (personalEmailAddress != null)
        "personalEmailAddress": personalEmailAddress,
      if (jobTitle != null) "jobTitle": jobTitle,
    };
  }
}

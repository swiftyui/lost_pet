import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lost_pet/src/models/pet_model.dart';

class LostPetsService extends ValueNotifier<List<PetModel>> {
  static late LostPetsService _instance;
  static LostPetsService get instance => _instance;
  late CollectionReference _lostPetsReference;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static initialise() async {
    _instance = LostPetsService._internal();
  }

  LostPetsService._internal() : super([]) {
    _subscribeToNotifications();
  }

  Future getNotifications({bool forceRefresh = false}) async {
    if (value.isEmpty || forceRefresh) {
      await _refreshNotifications();
    }
    return value;
  }

  Future _refreshNotifications() async {
    QuerySnapshot snapshot = await _lostPetsReference.get();
    value = List<PetModel>.empty(growable: true);
    for (var doc in snapshot.docs) {
      var json = doc.data() as Map<String, dynamic>;
      try {
        PetModel petModel = PetModel.fromJson(json);
        value.add(petModel);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  _subscribeToNotifications() async {
    _lostPetsReference = _firestore.collection("lostPets");

    _lostPetsReference.snapshots().listen(
      (subscription) {
        for (var doc in subscription.docs) {
          var foundPet = PetModel.fromJson(doc.data() as Map<String, dynamic>);
          print(foundPet.petName);
          value.add(foundPet);
        }
        notifyListeners();
      },
    );
  }
}

class PetModel {
  final String petName;

  PetModel({
    required this.petName,
  });

  Map<String, dynamic> toJson() {
    return {
      'petName': petName,
    };
  }

  PetModel.fromJson(Map<String, dynamic> jsonData)
      : petName = jsonData.containsKey('petName') ? jsonData['petName'] : '';
}

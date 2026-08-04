class LibraryDiseaseModel {
  final String id;
  final String name;
  final String scientificName;
  final String cropType;
  final String description;
  final List<String> causes;
  final List<LibrarySymptomModel> symptoms;
  final Map<String, LibraryTreatmentLevelModel> treatments;

  const LibraryDiseaseModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.cropType,
    required this.description,
    required this.causes,
    required this.symptoms,
    required this.treatments,
  });


  LibraryDiseaseModel copyWith({
    String? id,
    String? name,
    String? scientificName,
    String? cropType,
    String? description,
    List<String>? causes,
    List<LibrarySymptomModel>? symptoms,
    Map<String, LibraryTreatmentLevelModel>? treatments,
  }) {
    return LibraryDiseaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      cropType: cropType ?? this.cropType,
      description: description ?? this.description,
      causes: causes ?? this.causes,
      symptoms: symptoms ?? this.symptoms,
      treatments: treatments ?? this.treatments,
    );
  }

  factory LibraryDiseaseModel.fromJson(String id, Map<String, dynamic> json) {
    return LibraryDiseaseModel(
      id: id,
      name: json['common_name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      cropType: json['crop_type'] ?? '',
      description: json['overview'] ?? '',
      causes: List<String>.from(json['causes'] ?? []),
      symptoms: (json['symptoms'] as List?)
              ?.map((e) => LibrarySymptomModel.fromJson(e))
              .toList() ??
          [],
      treatments: (json['treatments'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, LibraryTreatmentLevelModel.fromJson(value)),
          ) ??
          {},
    );
  }
}

class LibrarySymptomModel {
  final String title;
  final String description;

  const LibrarySymptomModel({
    required this.title,
    required this.description,
  });


  LibrarySymptomModel copyWith({
    String? title,
    String? description,
  }) {
    return LibrarySymptomModel(
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  factory LibrarySymptomModel.fromJson(Map<String, dynamic> json) {
    return LibrarySymptomModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class LibraryTreatmentLevelModel {
  final List<LibraryOrganicTreatmentModel> organic;
  final LibraryChemicalTreatmentModel? chemical;
  final List<String> preventive;

  const LibraryTreatmentLevelModel({
    required this.organic,
    this.chemical,
    required this.preventive,
  });


  LibraryTreatmentLevelModel copyWith({
    List<LibraryOrganicTreatmentModel>? organic,
    LibraryChemicalTreatmentModel? chemical,
    List<String>? preventive,
  }) {
    return LibraryTreatmentLevelModel(
      organic: organic ?? this.organic,
      chemical: chemical ?? this.chemical,
      preventive: preventive ?? this.preventive,
    );
  }

  factory LibraryTreatmentLevelModel.fromJson(Map<String, dynamic> json) {
    return LibraryTreatmentLevelModel(
      organic: (json['organic'] as List?)
              ?.map((e) => LibraryOrganicTreatmentModel.fromJson(e))
              .toList() ??
          [],
      chemical: json['chemical'] != null
          ? LibraryChemicalTreatmentModel.fromJson(json['chemical'])
          : null,
      preventive: List<String>.from(json['preventive'] ?? []),
    );
  }
}

class LibraryOrganicTreatmentModel {
  final int step;
  final String title;
  final String description;

  const LibraryOrganicTreatmentModel({
    required this.step,
    required this.title,
    required this.description,
  });


  LibraryOrganicTreatmentModel copyWith({
    int? step,
    String? title,
    String? description,
  }) {
    return LibraryOrganicTreatmentModel(
      step: step ?? this.step,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  factory LibraryOrganicTreatmentModel.fromJson(Map<String, dynamic> json) {
    return LibraryOrganicTreatmentModel(
      step: json['step'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class LibraryChemicalTreatmentModel {
  final String safetyMessage;
  final List<LibraryChemicalProductModel> products;

  const LibraryChemicalTreatmentModel({
    required this.safetyMessage,
    required this.products,
  });


  LibraryChemicalTreatmentModel copyWith({
    String? safetyMessage,
    List<LibraryChemicalProductModel>? products,
  }) {
    return LibraryChemicalTreatmentModel(
      safetyMessage: safetyMessage ?? this.safetyMessage,
      products: products ?? this.products,
    );
  }

  factory LibraryChemicalTreatmentModel.fromJson(Map<String, dynamic> json) {
    return LibraryChemicalTreatmentModel(
      safetyMessage: json['safetyMessage'] ?? '',
      products: (json['products'] as List?)
              ?.map((e) => LibraryChemicalProductModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class LibraryChemicalProductModel {
  final String name;
  final String strength;
  final String description;
  final String dosage;

  const LibraryChemicalProductModel({
    required this.name,
    required this.strength,
    required this.description,
    required this.dosage,
  });


  LibraryChemicalProductModel copyWith({
    String? name,
    String? strength,
    String? description,
    String? dosage,
  }) {
    return LibraryChemicalProductModel(
      name: name ?? this.name,
      strength: strength ?? this.strength,
      description: description ?? this.description,
      dosage: dosage ?? this.dosage,
    );
  }

  factory LibraryChemicalProductModel.fromJson(Map<String, dynamic> json) {
    return LibraryChemicalProductModel(
      name: json['name'] ?? '',
      strength: json['strength'] ?? '',
      description: json['description'] ?? '',
      dosage: json['dosage'] ?? '',
    );
  }
}

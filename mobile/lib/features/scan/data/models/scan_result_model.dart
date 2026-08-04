class ScanResultModel {
  final int scanId;
  final ScanDataModel data;

  const ScanResultModel({
    required this.scanId,
    required this.data,
  });

    ScanResultModel copyWith({
    int? scanId,
    ScanDataModel? data,
  }) {
    return ScanResultModel(
      scanId: scanId ?? this.scanId,
      data: data ?? this.data,
    );
  }

factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('data') && json['data'] != null) {
      return ScanResultModel(
        scanId: json['scan_id'] ?? 0,
        data: ScanDataModel.fromJson(json['data']),
      );
    }
    
    // Fallback for extremely old backend responses that only have 'results'
    final res = json['results'] ?? {};
    final basic = res['basic_details'] ?? {};
    final diag = res['diagnostic_details'] ?? {};
    final treat = res['treatment_plan'] ?? {};
    final vis = res['visuals'] ?? {};
    
    final mappedData = {
      'diagnosisId': 'DG${(json['scan_id'] ?? 0).toString().padLeft(5, '0')}',
      'plant': {
        'name': '${basic['crop_type'] ?? ''} Plant',
        'captureDate': DateTime.now().toIso8601String().split('T')[0],
      },
      'disease': {
        'name': basic['disease_name'] ?? '',
        'scientificName': basic['scientific_name'] ?? '',
        'description': basic['summary'] ?? '',
      },
      'analysis': {
        'confidence': basic['confidence'] ?? 0,
        'infectionArea': basic['infection_percentage'] ?? 0,
        'severity': basic['severity'] ?? '',
        'severityMessage': basic['severity_message'] ?? '',
      },
      'causes': diag['causes'] ?? [],
      'symptoms': diag['symptoms'] ?? [],
      'highlight': {
        'overlayImageUrl': vis['heatmap_url'] ?? '',
        'gradcamUrl': vis['gradcam_url'] ?? '',
        'spotlightUrl': vis['spotlight_url'] ?? '',
        'opacity': 60,
      },
      'treatment': {
        'organic': treat['organic'] ?? [],
        'chemical': treat['chemical'],
        'preventive': diag['prevention'] ?? [],
      },
    };
    return ScanResultModel(
      scanId: json['scan_id'] ?? 0,
      data: ScanDataModel.fromJson(mappedData),
    );
  }
}

class ScanDataModel {
  final String diagnosisId;
  final PlantModel plant;
  final DiseaseModel disease;
  final AnalysisModel analysis;
  final List<String> causes;
  final List<SymptomModel> symptoms;
  final HighlightModel highlight;
  final TreatmentModel treatment;

  const ScanDataModel({
    required this.diagnosisId,
    required this.plant,
    required this.disease,
    required this.analysis,
    required this.causes,
    required this.symptoms,
    required this.highlight,
    required this.treatment,
  });

    ScanDataModel copyWith({
    String? diagnosisId,
    PlantModel? plant,
    DiseaseModel? disease,
    AnalysisModel? analysis,
    List<String>? causes,
    List<SymptomModel>? symptoms,
    HighlightModel? highlight,
    TreatmentModel? treatment,
  }) {
    return ScanDataModel(
      diagnosisId: diagnosisId ?? this.diagnosisId,
      plant: plant ?? this.plant,
      disease: disease ?? this.disease,
      analysis: analysis ?? this.analysis,
      causes: causes ?? this.causes,
      symptoms: symptoms ?? this.symptoms,
      highlight: highlight ?? this.highlight,
      treatment: treatment ?? this.treatment,
    );
  }

factory ScanDataModel.fromJson(Map<String, dynamic> json) {
    return ScanDataModel(
      diagnosisId: json['diagnosisId'] ?? '',
      plant: PlantModel.fromJson(json['plant'] ?? {}),
      disease: DiseaseModel.fromJson(json['disease'] ?? {}),
      analysis: AnalysisModel.fromJson(json['analysis'] ?? {}),
      causes: List<String>.from(json['causes'] ?? []),
      symptoms: (json['symptoms'] as List?)?.map((e) => SymptomModel.fromJson(e)).toList() ?? [],
      highlight: HighlightModel.fromJson(json['highlight'] ?? {}),
      treatment: TreatmentModel.fromJson(json['treatment'] ?? {}),
    );
  }
}

class PlantModel {
  final String name;
  final String captureDate;

  const PlantModel({required this.name, required this.captureDate});

    PlantModel copyWith({
    String? name,
    String? captureDate,
  }) {
    return PlantModel(
      name: name ?? this.name,
      captureDate: captureDate ?? this.captureDate,
    );
  }

factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      name: json['name'] ?? '',
      captureDate: json['captureDate'] ?? '',
    );
  }
}

class DiseaseModel {
  final String name;
  final String scientificName;
  final String description;

  const DiseaseModel({required this.name, required this.scientificName, required this.description});

    DiseaseModel copyWith({
    String? name,
    String? scientificName,
    String? description,
  }) {
    return DiseaseModel(
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      description: description ?? this.description,
    );
  }

factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      name: json['name'] ?? '',
      scientificName: json['scientificName'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class AnalysisModel {
  final num confidence;
  final num infectionArea;
  final String severity;
  final String severityMessage;

  const AnalysisModel({
    required this.confidence,
    required this.infectionArea,
    required this.severity,
    required this.severityMessage,
  });

    AnalysisModel copyWith({
    num? confidence,
    num? infectionArea,
    String? severity,
    String? severityMessage,
  }) {
    return AnalysisModel(
      confidence: confidence ?? this.confidence,
      infectionArea: infectionArea ?? this.infectionArea,
      severity: severity ?? this.severity,
      severityMessage: severityMessage ?? this.severityMessage,
    );
  }

factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    return AnalysisModel(
      confidence: json['confidence'] ?? 0,
      infectionArea: json['infectionArea'] ?? 0,
      severity: json['severity'] ?? '',
      severityMessage: json['severityMessage'] ?? '',
    );
  }
}

class SymptomModel {
  final String title;
  final String description;
  final String imageUrl;

  const SymptomModel({required this.title, required this.description, required this.imageUrl});

    SymptomModel copyWith({
    String? title,
    String? description,
    String? imageUrl,
  }) {
    return SymptomModel(
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

factory SymptomModel.fromJson(Map<String, dynamic> json) {
    return SymptomModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class HighlightModel {
  final String overlayImageUrl;
  final String gradcamUrl;
  final String spotlightUrl;
  final int opacity;

  const HighlightModel({
    required this.overlayImageUrl,
    required this.gradcamUrl,
    required this.spotlightUrl,
    required this.opacity,
  });

    HighlightModel copyWith({
    String? overlayImageUrl,
    String? gradcamUrl,
    String? spotlightUrl,
    int? opacity,
  }) {
    return HighlightModel(
      overlayImageUrl: overlayImageUrl ?? this.overlayImageUrl,
      gradcamUrl: gradcamUrl ?? this.gradcamUrl,
      spotlightUrl: spotlightUrl ?? this.spotlightUrl,
      opacity: opacity ?? this.opacity,
    );
  }

factory HighlightModel.fromJson(Map<String, dynamic> json) {
    return HighlightModel(
      overlayImageUrl: json['overlayImageUrl'] ?? '',
      gradcamUrl: json['gradcamUrl'] ?? '',
      spotlightUrl: json['spotlightUrl'] ?? '',
      opacity: json['opacity'] ?? 60,
    );
  }
}

class OrganicTreatmentModel {
  final int step;
  final String title;
  final String description;

  const OrganicTreatmentModel({required this.step, required this.title, required this.description});

    OrganicTreatmentModel copyWith({
    int? step,
    String? title,
    String? description,
  }) {
    return OrganicTreatmentModel(
      step: step ?? this.step,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

factory OrganicTreatmentModel.fromJson(Map<String, dynamic> json) {
    return OrganicTreatmentModel(
      step: json['step'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class ChemicalProductModel {
  final String name;
  final String strength;
  final String description;
  final String dosage;

  const ChemicalProductModel({required this.name, required this.strength, required this.description, required this.dosage});

    ChemicalProductModel copyWith({
    String? name,
    String? strength,
    String? description,
    String? dosage,
  }) {
    return ChemicalProductModel(
      name: name ?? this.name,
      strength: strength ?? this.strength,
      description: description ?? this.description,
      dosage: dosage ?? this.dosage,
    );
  }

factory ChemicalProductModel.fromJson(Map<String, dynamic> json) {
    return ChemicalProductModel(
      name: json['name'] ?? '',
      strength: json['strength'] ?? '',
      description: json['description'] ?? '',
      dosage: json['dosage'] ?? '',
    );
  }
}

class ChemicalTreatmentModel {
  final String safetyMessage;
  final List<ChemicalProductModel> products;

  const ChemicalTreatmentModel({required this.safetyMessage, required this.products});

    ChemicalTreatmentModel copyWith({
    String? safetyMessage,
    List<ChemicalProductModel>? products,
  }) {
    return ChemicalTreatmentModel(
      safetyMessage: safetyMessage ?? this.safetyMessage,
      products: products ?? this.products,
    );
  }

factory ChemicalTreatmentModel.fromJson(Map<String, dynamic> json) {
    return ChemicalTreatmentModel(
      safetyMessage: json['safetyMessage'] ?? '',
      products: (json['products'] as List?)?.map((e) => ChemicalProductModel.fromJson(e)).toList() ?? [],
    );
  }
}

class TreatmentModel {
  final List<OrganicTreatmentModel> organic;
  final ChemicalTreatmentModel? chemical;
  final List<String> preventive;

  const TreatmentModel({
    required this.organic,
    this.chemical,
    required this.preventive,
  });

  TreatmentModel copyWith({
    List<OrganicTreatmentModel>? organic,
    ChemicalTreatmentModel? chemical,
    List<String>? preventive,
  }) {
    return TreatmentModel(
      organic: organic ?? this.organic,
      chemical: chemical ?? this.chemical,
      preventive: preventive ?? this.preventive,
    );
  }

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      organic: (json['organic'] as List?)?.map((e) => OrganicTreatmentModel.fromJson(e)).toList() ?? [],
      chemical: json['chemical'] != null && json['chemical'] is Map<String, dynamic> 
          ? ChemicalTreatmentModel.fromJson(json['chemical']) 
          : null,
      preventive: List<String>.from(json['preventive'] ?? []),
    );
  }
}

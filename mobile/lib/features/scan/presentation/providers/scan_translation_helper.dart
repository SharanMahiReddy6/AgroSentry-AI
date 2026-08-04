import 'package:mobile/core/network/translation_service.dart';
import 'package:mobile/features/scan/data/models/scan_result_model.dart';

Future<ScanResultModel> translateScanResult(ScanResultModel result, TranslationService service, String lang) async {
  if (lang == 'en') return result;

  final data = result.data;
  
  final plant = data.plant.copyWith(
    name: await service.translateText(data.plant.name, lang),
  );
  
  final disease = data.disease.copyWith(
    name: await service.translateText(data.disease.name, lang),
    description: await service.translateText(data.disease.description, lang),
  );
  
  final analysis = data.analysis.copyWith(
    severity: await service.translateText(data.analysis.severity, lang),
    severityMessage: await service.translateText(data.analysis.severityMessage, lang),
  );
  
  final causes = <String>[];
  for (final cause in data.causes) {
    causes.add(await service.translateText(cause, lang));
  }
  
  final symptoms = <SymptomModel>[];
  for (final s in data.symptoms) {
    symptoms.add(s.copyWith(
      title: await service.translateText(s.title, lang),
      description: await service.translateText(s.description, lang),
    ));
  }
  
  final organic = <OrganicTreatmentModel>[];
  for (final o in data.treatment.organic) {
    organic.add(o.copyWith(
      title: await service.translateText(o.title, lang),
      description: await service.translateText(o.description, lang),
    ));
  }
  
  ChemicalTreatmentModel? chemical;
  if (data.treatment.chemical != null) {
    final products = <ChemicalProductModel>[];
    for (final p in data.treatment.chemical!.products) {
      products.add(p.copyWith(
        name: await service.translateText(p.name, lang),
        description: await service.translateText(p.description, lang),
        dosage: await service.translateText(p.dosage, lang),
      ));
    }
    chemical = data.treatment.chemical!.copyWith(
      safetyMessage: await service.translateText(data.treatment.chemical!.safetyMessage, lang),
      products: products,
    );
  }
  
  final preventive = <String>[];
  for (final p in data.treatment.preventive) {
    preventive.add(await service.translateText(p, lang));
  }
  
  final treatment = data.treatment.copyWith(
    organic: organic,
    chemical: chemical,
    preventive: preventive,
  );
  
  return result.copyWith(
    data: data.copyWith(
      plant: plant,
      disease: disease,
      analysis: analysis,
      causes: causes,
      symptoms: symptoms,
      treatment: treatment,
    ),
  );
}

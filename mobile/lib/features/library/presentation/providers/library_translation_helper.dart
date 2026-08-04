import 'package:mobile/core/network/translation_service.dart';
import 'package:mobile/features/library/data/models/library_disease_model.dart';

Future<LibraryDiseaseModel> translateDisease(LibraryDiseaseModel disease, TranslationService service, String lang) async {
  if (lang == 'en') return disease;
  
  final name = await service.translateText(disease.name, lang);
  final desc = await service.translateText(disease.description, lang);
  
  final causes = <String>[];
  for (final cause in disease.causes) {
    causes.add(await service.translateText(cause, lang));
  }
  
  final symptoms = <LibrarySymptomModel>[];
  for (final s in disease.symptoms) {
    symptoms.add(s.copyWith(
      title: await service.translateText(s.title, lang),
      description: await service.translateText(s.description, lang),
    ));
  }
  
  final treatments = <String, LibraryTreatmentLevelModel>{};
  for (final entry in disease.treatments.entries) {
    final t = entry.value;
    
    final organic = <LibraryOrganicTreatmentModel>[];
    for (final o in t.organic) {
      organic.add(o.copyWith(
        title: await service.translateText(o.title, lang),
        description: await service.translateText(o.description, lang),
      ));
    }
    
    LibraryChemicalTreatmentModel? chemical;
    if (t.chemical != null) {
      final products = <LibraryChemicalProductModel>[];
      for (final p in t.chemical!.products) {
        products.add(p.copyWith(
          name: await service.translateText(p.name, lang),
          description: await service.translateText(p.description, lang),
          dosage: await service.translateText(p.dosage, lang),
        ));
      }
      chemical = t.chemical!.copyWith(
        safetyMessage: await service.translateText(t.chemical!.safetyMessage, lang),
        products: products,
      );
    }
    
    final preventive = <String>[];
    for (final p in t.preventive) {
      preventive.add(await service.translateText(p, lang));
    }
    
    treatments[entry.key] = t.copyWith(
      organic: organic,
      chemical: chemical,
      preventive: preventive,
    );
  }
  
  return disease.copyWith(
    name: name,
    description: desc,
    causes: causes,
    symptoms: symptoms,
    treatments: treatments,
  );
}

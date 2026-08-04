import 'package:mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/features/library/data/models/library_disease_model.dart';

class DiseaseDetailScreen extends StatefulWidget {
  final LibraryDiseaseModel disease;

  const DiseaseDetailScreen({
    super.key,
    required this.disease,
  });

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  String _selectedSeverity = 'Medium';

  @override
  Widget build(BuildContext context) {
    final disease = widget.disease;
    final isHealthy = disease.name.toLowerCase().contains('healthy');
    final theme = Theme.of(context);

    return AppScaffold(
      title: (AppLocalizations.of(context)?.diseaseDetails ?? 'Disease Details'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isHealthy ? Colors.green.shade100 : Colors.red.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: 'Disease Name: ${disease.name}',
                    child: Text(
                      disease.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isHealthy ? Colors.green.shade900 : Colors.red.shade900,
                      ),
                    ),
                  ),
                  if (disease.scientificName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        disease.scientificName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: isHealthy ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(disease.cropType),
                    backgroundColor: theme.colorScheme.surface,
                    side: BorderSide.none,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle(context, 'Overview'),
                  Text(
                    disease.description,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  if (disease.causes.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Causes'),
                    ...disease.causes.map((cause) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.arrow_right, color: Colors.grey),
                              Expanded(
                                child: Text(cause, style: const TextStyle(height: 1.4)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  if (disease.symptoms.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Symptoms'),
                    ...disease.symptoms.map((symptom) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ExpansionTile(
                            title: Text(symptom.title,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            childrenPadding: const EdgeInsets.all(16.0),
                            children: [
                              Text(symptom.description,
                                  style: const TextStyle(height: 1.4)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  if (disease.treatments.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Treatment Plan'),
                    
                    // Severity Selector
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(value: 'Low', label: Text((AppLocalizations.of(context)?.lowSeverity ?? 'Low Severity'))),
                        ButtonSegment(value: 'Medium', label: Text((AppLocalizations.of(context)?.mediumSeverity ?? 'Medium Severity'))),
                        ButtonSegment(value: 'High', label: Text((AppLocalizations.of(context)?.highSeverity ?? 'High Severity'))),
                      ],
                      selected: {_selectedSeverity},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedSeverity = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    if (disease.treatments.containsKey(_selectedSeverity))
                      _buildTreatmentView(
                          context, disease.treatments[_selectedSeverity]!),
                    
                    if (!disease.treatments.containsKey(_selectedSeverity))
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(child: Text((AppLocalizations.of(context)?.noSpecificTreatmentsAvailableForThisSeve ?? 'No specific treatments available for this severity level.'))),
                      ),
                      
                    const SizedBox(height: 48),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTreatmentView(BuildContext context, LibraryTreatmentLevelModel treatment) {
    return Column(
      children: [
        if (treatment.organic.isNotEmpty)
          Semantics(
            label: (AppLocalizations.of(context)?.organicTreatments ?? 'Organic Treatments'),
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                initiallyExpanded: true,
                leading: const Icon(Icons.eco, color: Colors.green),
                title: Text((AppLocalizations.of(context)?.organicTreatment ?? 'Organic Treatment'), style: const TextStyle(fontWeight: FontWeight.w600)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: treatment.organic.map((org) => Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.green.shade100,
                        child: Text('${org.step}', style: TextStyle(fontSize: 12, color: Colors.green.shade900, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(org.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(org.description, style: const TextStyle(height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),

        if (treatment.chemical != null && treatment.chemical!.products.isNotEmpty)
          Semantics(
            label: (AppLocalizations.of(context)?.chemicalTreatments ?? 'Chemical Treatments'),
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                initiallyExpanded: false,
                leading: const Icon(Icons.science, color: Colors.blue),
                title: Text((AppLocalizations.of(context)?.chemicalTreatment ?? 'Chemical Treatment'), style: const TextStyle(fontWeight: FontWeight.w600)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  if (treatment.chemical!.safetyMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                          const SizedBox(width: 8),
                          Expanded(child: Text(treatment.chemical!.safetyMessage, style: TextStyle(color: Colors.amber.shade900))),
                        ],
                      ),
                    ),
                  ...treatment.chemical!.products.map((prod) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Chip(
                              label: Text(prod.strength, style: const TextStyle(fontSize: 10)),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(prod.description, style: const TextStyle(height: 1.4)),
                        const SizedBox(height: 4),
                        Text('Dosage: ${prod.dosage}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                      ],
                    ),
                  ))
                ],
              ),
            ),
          ),

        if (treatment.preventive.isNotEmpty)
          Semantics(
            label: (AppLocalizations.of(context)?.preventiveMeasures ?? 'Preventive Measures'),
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                initiallyExpanded: false,
                leading: const Icon(Icons.shield, color: Colors.purple),
                title: Text((AppLocalizations.of(context)?.preventiveMeasures ?? 'Preventive Measures'), style: const TextStyle(fontWeight: FontWeight.w600)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: treatment.preventive.map((prev) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Expanded(child: Text(prev, style: const TextStyle(height: 1.4))),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

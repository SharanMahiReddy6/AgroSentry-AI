import 'package:mobile/l10n/app_localizations.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/core/env/env.dart';
import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/features/scan/presentation/providers/scan_provider.dart';
import 'package:mobile/features/scan/data/models/scan_result_model.dart';

class ScanResultScreen extends ConsumerWidget {
  const ScanResultScreen({super.key});

  String _buildUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final base = Env.apiBaseUrl.replaceAll(RegExp(r'/api/?$'), '');
    return '$base$path';
  }

  void _showImagePreview(BuildContext context, String title, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: _buildUrl(imageUrl),
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 64, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanProvider);
    
    if (state.isLoadingDetails) {
      return AppScaffold(
        title: (AppLocalizations.of(context)?.scanResult ?? 'Scan Result'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text((AppLocalizations.of(context)?.loadingScanDetails ?? 'Loading scan details...')),
            ],
          ),
        ),
      );
    }

    final result = state.scanResult;

    if (result == null) {
      return AppScaffold(
        title: (AppLocalizations.of(context)?.scanResult ?? 'Scan Result'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text((AppLocalizations.of(context)?.scanResultNotFoundOrExpired ?? 'Scan result not found or expired.')),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: Text((AppLocalizations.of(context)?.backToDashboard ?? 'Back to Dashboard')),
              ),
            ],
          ),
        ),
      );
    }

    final data = result.data;
    final isHealthy = data.disease.name.toLowerCase().contains('healthy');
    final statusColor = isHealthy ? Colors.green : Colors.redAccent;

    return AppScaffold(
      title: (AppLocalizations.of(context)?.scanResult ?? 'Scan Result'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, state, data, statusColor, isHealthy),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAnalysisSummary(context, data.analysis, statusColor),
                  const SizedBox(height: 24),
                  if (!isHealthy && data.highlight.overlayImageUrl.isNotEmpty) ...[
                    _buildVisualAnalysis(context, data.highlight),
                    const SizedBox(height: 24),
                  ],
                  _buildDiseaseInfo(context, data.disease, data.analysis),
                  const SizedBox(height: 24),
                  if (data.causes.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Causes'),
                    ...data.causes.map((cause) => ListTile(
                      leading: const Icon(Icons.arrow_right),
                      title: Text(cause),
                      contentPadding: EdgeInsets.zero,
                    )),
                    const SizedBox(height: 24),
                  ],
                  if (data.symptoms.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Symptoms'),
                    _buildSymptoms(context, data.symptoms),
                    const SizedBox(height: 24),
                  ],
                  if (!isHealthy) ...[
                    _buildSectionTitle(context, 'Treatment Plan'),
                    _buildTreatments(context, data.treatment),
                    const SizedBox(height: 32),
                  ],
                  _buildActionButtons(context, ref),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ScanState state, ScanDataModel data, Color statusColor, bool isHealthy) {
    return Stack(
      children: [
        if (state.imageFile != null)
          Image.file(
            File(state.imageFile!.path),
            width: double.infinity,
            height: 280,
            fit: BoxFit.cover,
          )
        else
          Container(
            width: double.infinity,
            height: 280,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 64, color: Colors.grey),
          ),
        Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isHealthy ? 'HEALTHY' : 'DISEASE DETECTED',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    data.plant.captureDate,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Disease Name: ${data.disease.name}',
                child: Text(
                  data.disease.name,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              if (data.disease.scientificName.isNotEmpty)
                Text(
                  data.disease.scientificName,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
                ),
              const SizedBox(height: 8),
              Text(
                'ID: ${data.diagnosisId} • Plant: ${data.plant.name}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisSummary(BuildContext context, AnalysisModel analysis, Color statusColor) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context, 
            'Confidence', 
            '${analysis.confidence}%', 
            Icons.analytics_outlined,
            Colors.blue,
            'Confidence: ${analysis.confidence} percent',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context, 
            'Severity', 
            analysis.severity, 
            Icons.warning_amber_rounded,
            statusColor,
            'Severity: ${analysis.severity}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context, 
            'Infected Area', 
            '${analysis.infectionArea}%', 
            Icons.pie_chart_outline,
            Colors.orange,
            'Infected Area: ${analysis.infectionArea} percent',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color color, String semanticsLabel) {
    return Semantics(
      label: semanticsLabel,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
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
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildVisualAnalysis(BuildContext context, HighlightModel highlight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(context, 'Visual Analysis'),
        Semantics(
          label: (AppLocalizations.of(context)?.visualAnalysisImagesShowingGradcamAndLes ?? 'Visual analysis images showing Grad-CAM and Lesion Spotlight'),
          child: Row(
            children: [
              if (highlight.gradcamUrl.isNotEmpty)
                Expanded(
                  child: _buildThumbnail(context, 'Grad-CAM', highlight.gradcamUrl),
                ),
              if (highlight.gradcamUrl.isNotEmpty && highlight.spotlightUrl.isNotEmpty)
                const SizedBox(width: 16),
              if (highlight.spotlightUrl.isNotEmpty)
                Expanded(
                  child: _buildThumbnail(context, 'Lesion Spotlight', highlight.spotlightUrl),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context, String title, String imageUrl) {
    return GestureDetector(
      onTap: () => _showImagePreview(context, title, imageUrl),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: _buildUrl(imageUrl),
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 120,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 120,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDiseaseInfo(BuildContext context, DiseaseModel disease, AnalysisModel analysis) {
    if (disease.description.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(context, 'Overview'),
        Text(
          disease.description,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        if (analysis.severityMessage.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              border: Border.all(color: Colors.amber.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              analysis.severityMessage,
              style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSymptoms(BuildContext context, List<SymptomModel> symptoms) {
    return Column(
      children: symptoms.map((symptom) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(symptom.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            childrenPadding: const EdgeInsets.all(16.0),
            children: [
              if (symptom.imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: _buildUrl(symptom.imageUrl),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              Text(symptom.description, style: const TextStyle(height: 1.4)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTreatments(BuildContext context, TreatmentModel treatment) {
    return Column(
      children: [
        if (treatment.organic.isNotEmpty)
          _buildOrganicCard(context, treatment.organic),
        if (treatment.chemical != null)
          _buildChemicalCard(context, treatment.chemical!),
        if (treatment.preventive.isNotEmpty)
          _buildTreatmentCard(context, 'Preventive Measures', Icons.shield, Colors.purple, treatment.preventive),
      ],
    );
  }

  Widget _buildOrganicCard(BuildContext context, List<OrganicTreatmentModel> organic) {
    return Semantics(
      label: (AppLocalizations.of(context)?.treatmentSectionOrganicTreatment ?? 'Treatment section: Organic Treatment'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          leading: const Icon(Icons.eco, color: Colors.green),
          title: Text((AppLocalizations.of(context)?.organicTreatment ?? 'Organic Treatment'), style: const TextStyle(fontWeight: FontWeight.w600)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: organic.map((step) => Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${step.step}. ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(step.description, style: const TextStyle(height: 1.4)),
                  ],
                )),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildChemicalCard(BuildContext context, ChemicalTreatmentModel chemical) {
    return Semantics(
      label: (AppLocalizations.of(context)?.treatmentSectionChemicalTreatment ?? 'Treatment section: Chemical Treatment'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          leading: const Icon(Icons.science, color: Colors.blue),
          title: Text((AppLocalizations.of(context)?.chemicalTreatment ?? 'Chemical Treatment'), style: const TextStyle(fontWeight: FontWeight.w600)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            if (chemical.safetyMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(chemical.safetyMessage, style: const TextStyle(fontSize: 13, color: Colors.black87))),
                  ],
                ),
              ),
            ...chemical.products.map((product) => Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.strength == 'Strong' ? Colors.red : (product.strength == 'Medium' ? Colors.orange : Colors.green),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(product.strength, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(product.description, style: const TextStyle(height: 1.4, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Dosage: ${product.dosage}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
                  const Divider(),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentCard(BuildContext context, String title, IconData icon, Color color, List<String> steps) {
    return Semantics(
      label: 'Treatment section: $title',
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: steps.map((step) => Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Expanded(child: Text(step, style: const TextStyle(height: 1.4))),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            ref.read(scanProvider.notifier).removeImage();
            context.go('/scan');
          },
          icon: const Icon(Icons.camera_alt),
          label: Text((AppLocalizations.of(context)?.scanAnotherPlant ?? 'Scan Another Plant'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text((AppLocalizations.of(context)?.savedToHistory ?? 'Saved to history.'))),
                  );
                },
                icon: const Icon(Icons.bookmark_border),
                label: Text((AppLocalizations.of(context)?.saveResult ?? 'Save Result')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.home_outlined),
                label: Text((AppLocalizations.of(context)?.dashboard ?? 'Dashboard')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

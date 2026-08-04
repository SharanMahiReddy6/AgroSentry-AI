import 'package:mobile/l10n/app_localizations.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/features/scan/presentation/providers/scan_provider.dart';

const List<String> supportedCrops = ['Apple', 'Blueberry', 'Cherry', 'Corn', 'Grape', 'Orange', 'Peach', 'Pepper (Bell)', 'Potato'];

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  void _showErrorDialog(String error, bool retryable) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text((AppLocalizations.of(context)?.uploadFailed ?? 'Upload Failed')),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(retryable ? 'Cancel' : 'OK'),
          ),
          if (retryable)
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(scanProvider.notifier).uploadScan();
              },
              child: Text((AppLocalizations.of(context)?.retry ?? 'Retry')),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanProvider);
    final notifier = ref.read(scanProvider.notifier);

    ref.listen<ScanState>(scanProvider, (previous, next) {
      if (next.permissionError != null && next.permissionError != previous?.permissionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.permissionError!), backgroundColor: Colors.red),
        );
      }
      
      if (next.uploadStatus == UploadStatus.success && previous?.uploadStatus != UploadStatus.success) {
        context.push('/scan/result');
      }

      if (next.uploadStatus == UploadStatus.failed && next.uploadError != null && previous?.uploadStatus != UploadStatus.failed) {
        final error = next.uploadError!;
        final retryable = error.contains('timed out') || error.contains('internet') || error.contains('server error');
        _showErrorDialog(error, retryable);
      }
    });

    final isUploading = state.isUploading;

    return AppScaffold(
      title: (AppLocalizations.of(context)?.scanPlant ?? 'Scan Plant'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePreview(context, state, notifier),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isUploading ? null : () => notifier.pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text((AppLocalizations.of(context)?.camera ?? 'Camera')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isUploading ? null : () => notifier.pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text((AppLocalizations.of(context)?.gallery ?? 'Gallery')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            Text((AppLocalizations.of(context)?.selectCropType ?? 'Select Crop Type'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: supportedCrops.map((crop) {
                return ChoiceChip(
                  label: Text(crop),
                  selected: state.selectedCrop == crop,
                  onSelected: isUploading ? null : (selected) {
                    if (selected) {
                      notifier.selectCrop(crop);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 48),

            isUploading
                ? Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text((AppLocalizations.of(context)?.analyzingTissuePatterns ?? 'Analyzing Tissue Patterns...'), style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => notifier.cancelUpload(),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: Text((AppLocalizations.of(context)?.cancelUpload ?? 'Cancel Upload'), style: const TextStyle(color: Colors.red)),
                      )
                    ],
                  )
                : ElevatedButton(
                    onPressed: state.isValid ? () => notifier.uploadScan() : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text((AppLocalizations.of(context)?.analyzePlant ?? 'Analyze Plant'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, ScanState state, ScanNotifier notifier) {
    if (state.imageFile == null) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text((AppLocalizations.of(context)?.noImageSelected ?? 'No image selected'), style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            File(state.imageFile!.path),
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        if (!state.isUploading)
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => notifier.pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  tooltip: 'Replace image',
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => notifier.removeImage(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  tooltip: 'Remove image',
                ),
              ],
            ),
          ),
      ],
    );
  }
}

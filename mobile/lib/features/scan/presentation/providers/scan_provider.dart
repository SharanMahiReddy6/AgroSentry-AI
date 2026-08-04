import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/scan/data/models/scan_result_model.dart';
import 'package:mobile/features/scan/data/repositories/scan_repository_impl.dart';
import 'package:mobile/core/network/translation_service.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/scan/presentation/providers/scan_translation_helper.dart';

enum UploadStatus { idle, uploading, success, failed }

class ScanState {
  final XFile? imageFile;
  final String? selectedCrop;
  final String? permissionError;
  final UploadStatus uploadStatus;
  final String? uploadError;
  final ScanResultModel? scanResult;
  final bool isLoadingDetails;
  final String? detailsError;

  const ScanState({
    this.imageFile,
    this.selectedCrop = 'Apple',
    this.permissionError,
    this.uploadStatus = UploadStatus.idle,
    this.uploadError,
    this.scanResult,
    this.isLoadingDetails = false,
    this.detailsError,
  });

  ScanState copyWith({
    XFile? imageFile,
    String? selectedCrop,
    String? permissionError,
    UploadStatus? uploadStatus,
    String? uploadError,
    ScanResultModel? scanResult,
    bool? isLoadingDetails,
    String? detailsError,
    bool clearImage = false,
    bool clearPermissionError = false,
    bool clearUploadError = false,
    bool clearDetailsError = false,
  }) {
    return ScanState(
      imageFile: clearImage ? null : (imageFile ?? this.imageFile),
      selectedCrop: selectedCrop ?? this.selectedCrop,
      permissionError: clearPermissionError ? null : (permissionError ?? this.permissionError),
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadError: clearUploadError ? null : (uploadError ?? this.uploadError),
      scanResult: scanResult ?? this.scanResult,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      detailsError: clearDetailsError ? null : (detailsError ?? this.detailsError),
    );
  }

  bool get isValid => imageFile != null && selectedCrop != null;
  bool get isUploading => uploadStatus == UploadStatus.uploading;
}

class ScanNotifier extends StateNotifier<ScanState> {
  final ImagePicker _picker;
  final Ref _ref;
  CancelToken? _cancelToken;

  ScanNotifier({ImagePicker? picker, required Ref ref}) 
      : _picker = picker ?? ImagePicker(), 
        _ref = ref,
        super(const ScanState());

  @override
  void dispose() {
    _cancelToken?.cancel('Notifier disposed');
    super.dispose();
  }

  void cancelUpload() {
    if (state.uploadStatus == UploadStatus.uploading) {
      _cancelToken?.cancel('Upload cancelled by user');
      state = state.copyWith(
        uploadStatus: UploadStatus.idle,
        clearUploadError: true,
      );
    }
  }

  Future<void> uploadScan() async {
    if (!state.isValid || state.uploadStatus == UploadStatus.uploading) return;

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    state = state.copyWith(uploadStatus: UploadStatus.uploading, clearUploadError: true);

    try {
      final repository = _ref.read(scanRepositoryProvider);
      final rawResult = await repository.uploadScan(
        state.imageFile!.path,
        state.selectedCrop!,
        _cancelToken!,
      );
      
      final targetLang = _ref.read(authProvider).user?.language ?? 'en';
      final translationService = _ref.read(translationServiceProvider);
      final result = await translateScanResult(rawResult, translationService, targetLang);

      if (!mounted) return;
      state = state.copyWith(
        uploadStatus: UploadStatus.success,
        scanResult: result,
      );
    } catch (e) {
      if (!mounted) return;
      
      // Do not show errors if it was cancelled explicitly
      if (e is Failure && e.message.contains('cancelled')) {
        state = state.copyWith(
          uploadStatus: UploadStatus.idle,
          clearUploadError: true,
        );
        return;
      }
      
      state = state.copyWith(
        uploadStatus: UploadStatus.failed,
        uploadError: e is Failure ? e.message : e.toString(),
      );
    }
  }

  Future<void> pickImage(ImageSource source, {bool bypassPermissionsForTest = false}) async {
    state = state.copyWith(clearPermissionError: true);
    
    if (source == ImageSource.camera && !bypassPermissionsForTest) {
      final status = await Permission.camera.request();
      if (status.isPermanentlyDenied) {
        state = state.copyWith(permissionError: 'Camera permission permanently denied. Please enable in settings.');
        return;
      } else if (status.isDenied) {
        state = state.copyWith(permissionError: 'Camera permission denied.');
        return;
      }
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (pickedFile != null) {
        state = state.copyWith(imageFile: pickedFile);
      }
    } catch (e) {
      state = state.copyWith(permissionError: 'Error accessing media: ${e.toString()}');
    }
  }

  void selectCrop(String crop) {
    state = state.copyWith(selectedCrop: crop);
  }

  void removeImage() {
    state = state.copyWith(clearImage: true);
  }

  Future<void> fetchScanDetails(int scanId) async {
    // Cache check
    if (state.scanResult?.scanId == scanId) {
      return; // Already loaded this scan
    }

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    state = state.copyWith(isLoadingDetails: true, clearDetailsError: true);

    try {
      final repository = _ref.read(scanRepositoryProvider);
      final rawResult = await repository.getScanDetails(scanId, _cancelToken!);

      final targetLang = _ref.read(authProvider).user?.language ?? 'en';
      final translationService = _ref.read(translationServiceProvider);
      final result = await translateScanResult(rawResult, translationService, targetLang);

      if (!mounted) return;
      state = state.copyWith(
        isLoadingDetails: false,
        scanResult: result,
      );
    } catch (e) {
      if (!mounted) return;
      
      if (e is Failure && e.message.contains('cancelled')) {
        state = state.copyWith(isLoadingDetails: false);
        return;
      }
      
      state = state.copyWith(
        isLoadingDetails: false,
        detailsError: e is Failure ? e.message : e.toString(),
      );
    }
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(ref: ref);
});

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/features/scan/presentation/providers/scan_provider.dart';

class MockImagePicker extends ImagePicker {
  XFile? mockFile;
  Exception? exception;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    if (exception != null) throw exception!;
    return mockFile;
  }
}

void main() {
  late ProviderContainer container;
  late MockImagePicker mockPicker;

  setUp(() {
    container = ProviderContainer();
    mockPicker = MockImagePicker();
    
    // We can't inject mockPicker directly via ProviderContainer easily without overriding the provider
    // if the provider took it. So we just instantiate it manually with the container's ref.
    // Wait, StateNotifier expects a Ref. It's safer to override the provider:
  });

  tearDown(() {
    container.dispose();
  });

  test('Initial state', () {
    // Actually we can just override it
    final provider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
      return ScanNotifier(picker: mockPicker, ref: ref);
    });
    
    final state = container.read(provider);
    expect(state.imageFile, isNull);
    expect(state.uploadStatus, UploadStatus.idle);
  });
}

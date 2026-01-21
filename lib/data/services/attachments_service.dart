import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attachment_ref.dart';

abstract class AttachmentsService {
  Future<List<AttachmentRef>> pickPhotos();
  Future<AttachmentRef?> recordAudio();
  Future<AttachmentRef?> captureHandwriting();
}

class StubAttachmentsService implements AttachmentsService {
  @override
  Future<List<AttachmentRef>> pickPhotos() async => [];

  @override
  Future<AttachmentRef?> recordAudio() async => null;

  @override
  Future<AttachmentRef?> captureHandwriting() async => null;
}

final attachmentsServiceProvider = Provider<AttachmentsService>((ref) {
  return StubAttachmentsService();
});

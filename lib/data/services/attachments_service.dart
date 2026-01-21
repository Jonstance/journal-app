import 'package:flutter_riverpod/flutter_riverpod.dart';

class Attachment {
  const Attachment({required this.id, required this.path, required this.type});

  final String id;
  final String path;
  final AttachmentType type;
}

enum AttachmentType { photo, audio, handwriting }

abstract class AttachmentsService {
  Future<List<Attachment>> pickPhotos();
  Future<Attachment?> recordAudio();
  Future<Attachment?> captureHandwriting();
}

class StubAttachmentsService implements AttachmentsService {
  @override
  Future<List<Attachment>> pickPhotos() async => [];

  @override
  Future<Attachment?> recordAudio() async => null;

  @override
  Future<Attachment?> captureHandwriting() async => null;
}

final attachmentsServiceProvider = Provider<AttachmentsService>((ref) {
  return StubAttachmentsService();
});

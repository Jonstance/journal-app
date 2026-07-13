import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../models/attachment_ref.dart';

abstract class AttachmentsService {
  Future<List<AttachmentRef>> pickPhotos();
  Future<bool> startRecording();
  Future<AttachmentRef?> stopRecording();
  Future<AttachmentRef?> captureHandwriting();
}

class RecordingAttachmentsService implements AttachmentsService {
  final _recorder = AudioRecorder();

  @override
  Future<List<AttachmentRef>> pickPhotos() async => [];

  @override
  Future<AttachmentRef?> captureHandwriting() async => null;

  @override
  Future<bool> startRecording() async {
    if (!await _recorder.hasPermission()) return false;

    final docsDir = await getApplicationDocumentsDirectory();
    final memosDir = Directory('${docsDir.path}/voice_memos');
    if (!await memosDir.exists()) {
      await memosDir.create(recursive: true);
    }
    final path = '${memosDir.path}/${const Uuid().v4()}.m4a';

    await _recorder.start(const RecordConfig(), path: path);
    return true;
  }

  @override
  Future<AttachmentRef?> stopRecording() async {
    final path = await _recorder.stop();
    if (path == null) return null;
    return AttachmentRef(path: path, type: AttachmentType.audio);
  }

  void dispose() {
    _recorder.dispose();
  }
}

final attachmentsServiceProvider = Provider<AttachmentsService>((ref) {
  final service = RecordingAttachmentsService();
  ref.onDispose(service.dispose);
  return service;
});

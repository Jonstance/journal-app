import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/backup_codec.dart';
import '../models/journal_entry.dart';
import '../repositories/local_journal_repository.dart';
import '../repositories/journal_repository.dart';

abstract class ExportService {
  Future<void> exportPdf();
  Future<File?> exportEncryptedBackup({required String passphrase});
  Future<int> importEncryptedBackup({required String passphrase});
}

class LocalExportService implements ExportService {
  LocalExportService(this._repository, this._codec);

  final JournalRepository _repository;
  final BackupCodec _codec;

  @override
  Future<void> exportPdf() async {}

  @override
  Future<File?> exportEncryptedBackup({required String passphrase}) async {
    final entries = await _repository.getAllEntries();
    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'entries': entries.map((entry) => entry.toMap()).toList(),
    };

    final plain = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
    final envelope = await _codec.encrypt(passphrase, plain);
    final backupBytes = Uint8List.fromList(utf8.encode(jsonEncode(envelope.toJson())));

    final filename = 'velvet_backup_${DateTime.now().millisecondsSinceEpoch}.journal';
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save journal backup',
      fileName: filename,
      allowedExtensions: ['journal'],
      type: FileType.custom,
    );
    if (savePath == null) return null;

    final file = File(savePath);
    await file.writeAsBytes(backupBytes, flush: true);
    return file;
  }

  @override
  Future<int> importEncryptedBackup({required String passphrase}) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import journal backup',
      type: FileType.custom,
      allowedExtensions: ['journal'],
    );
    if (result == null || result.files.single.path == null) {
      return 0;
    }

    final path = result.files.single.path!;
    final bytes = await File(path).readAsBytes();
    final decoded = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    final envelope = BackupEnvelope.fromJson(decoded);
    final clear = await _codec.decrypt(passphrase, envelope);
    final payload = jsonDecode(utf8.decode(clear)) as Map<String, dynamic>;
    final rawEntries = payload['entries'] as List<dynamic>? ?? [];
    final entries = rawEntries
        .map((entry) => JournalEntry.fromMap(entry as Map<String, dynamic>))
        .toList();

    await _repository.replaceAllEntries(entries);
    return entries.length;
  }
}

final exportServiceProvider = Provider<ExportService>((ref) {
  final repository = ref.read(journalRepositoryProvider);
  return LocalExportService(repository, BackupCodec.standard());
});

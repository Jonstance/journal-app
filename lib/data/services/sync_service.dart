import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncState {
  const SyncState({required this.enabled, this.lastSyncedAt});

  final bool enabled;
  final DateTime? lastSyncedAt;
}

abstract class SyncService {
  Stream<SyncState> watchSync();
  Future<void> enableSync();
  Future<void> disableSync();
}

class StubSyncService implements SyncService {
  final _controller = Stream<SyncState>.value(const SyncState(enabled: false));

  @override
  Stream<SyncState> watchSync() => _controller;

  @override
  Future<void> enableSync() async {}

  @override
  Future<void> disableSync() async {}
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return StubSyncService();
});

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'backup_repository.dart';

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => NoOpBackupRepository(),
);

class NoOpBackupRepository implements BackupRepository {
  @override
  Future<void> upload(File _) async {}

  @override
  Future<File?> downloadLatest() async => null;

  @override
  Future<DateTime?> lastBackupDate() async => null;
}

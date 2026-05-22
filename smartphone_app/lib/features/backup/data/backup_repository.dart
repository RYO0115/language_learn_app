import 'dart:io';

abstract class BackupRepository {
  Future<void> upload(File dbFile);
  Future<File?> downloadLatest();
  Future<DateTime?> lastBackupDate();
}

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

enum StorageStatus { ok, warning, over }

class StorageMonitor {
  StorageMonitor({int limitMb = 100}) : limitBytes = limitMb * 1024 * 1024;

  final int limitBytes;

  Future<int> getDatabaseSizeBytes() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'language_learn.db'));
    if (!await file.exists()) return 0;
    return await file.length();
  }

  Future<bool> isOverLimit() async {
    final size = await getDatabaseSizeBytes();
    return size > limitBytes;
  }

  Future<StorageStatus> check() async {
    final size = await getDatabaseSizeBytes();
    if (size > limitBytes) return StorageStatus.over;
    if (size > limitBytes * 0.9) return StorageStatus.warning;
    return StorageStatus.ok;
  }
}

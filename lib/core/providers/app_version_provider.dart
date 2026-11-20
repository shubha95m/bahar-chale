import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    if (info.version.isNotEmpty) {
      return 'v${info.version} (Build ${info.buildNumber})';
    }
    return 'v1.0.1 (Build 2)';
  } catch (_) {
    return 'v1.0.1 (Build 2)';
  }
});

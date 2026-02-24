import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final appPackageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

final appDisplayVersionProvider = Provider<String>((ref) {
  final packageInfo = ref.watch(appPackageInfoProvider).asData?.value;
  if (packageInfo != null) {
    final version = packageInfo.version.trim();
    final buildNumber = packageInfo.buildNumber.trim();
    if (version.isNotEmpty && buildNumber.isNotEmpty) {
      return '$version+$buildNumber';
    }
    if (version.isNotEmpty) {
      return version;
    }
  }

  return _fallbackDisplayVersion;
});

final appSemanticVersionProvider = Provider<String?>((ref) {
  final packageVersion = ref.watch(appPackageInfoProvider).asData?.value;
  final normalizedPackageVersion = packageVersion?.version.trim();
  if (normalizedPackageVersion != null && normalizedPackageVersion.isNotEmpty) {
    return normalizedPackageVersion;
  }

  final normalizedEnvVersion = _envAppVersion.trim();
  if (normalizedEnvVersion.isNotEmpty) {
    return normalizedEnvVersion;
  }

  return null;
});

const _envAppVersion = String.fromEnvironment('APP_VERSION', defaultValue: '');
const _envAppBuildNumber = String.fromEnvironment(
  'APP_BUILD_NUMBER',
  defaultValue: '',
);

String get _fallbackDisplayVersion {
  final version = _envAppVersion.trim();
  final buildNumber = _envAppBuildNumber.trim();

  if (version.isNotEmpty && buildNumber.isNotEmpty) {
    return '$version+$buildNumber';
  }
  if (version.isNotEmpty) {
    return version;
  }

  return '-';
}

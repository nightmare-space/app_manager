import 'package:app_manager/model/app_details.dart';

class AppInfo {
  AppInfo(
    this.packageName, {
    this.appName = '',
    this.uid,
    this.apkPath = '',
    this.freeze = false,
    this.hide = false,
    this.minSdk,
    this.targetSdk,
    this.versionCode,
    this.versionName,
  });
  final String packageName;
  String iconPath = '';
  String appName;
  final String apkPath;
  String targetSdk = '';
  String minSdk = '';
  String versionName = '';
  String versionCode = '';
  bool freeze;
  bool hide;
  final String uid;
  AppDetails details;

  AppInfo copyWith(AppInfo other) {
    AppInfo appEntity = AppInfo(packageName);
    appEntity.appName = other.appName;
    appEntity.minSdk = other.minSdk;
    appEntity.targetSdk = other.targetSdk;
    appEntity.versionName = other.versionName;
    appEntity.versionCode = other.versionCode;
    return appEntity;
  }

  @override
  String toString() {
    return 'appName : $appName packageName : $packageName';
  }

  @override
  bool operator ==(dynamic other) {
    // 判断是否是非
    if (other is! AppInfo) {
      return false;
    }
    if (other is AppInfo) {
      final AppInfo entity = other;
      return packageName == entity.packageName;
    }
    return false;
  }

  @override
  int get hashCode => packageName.hashCode;
}

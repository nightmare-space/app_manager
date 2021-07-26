class AppEntity {
  AppEntity(
    this.packageName,
    this.appName, {
    this.apkPath = '',
  });
  final String packageName;
  String iconPath = '';
  String appName;
  final String apkPath;
  String targetSdk = '';
  String minSdk = '';
  String versionName = '';
  String versionCode = '';
  @override
  String toString() {
    return 'appName : $appName packageName : $packageName';
  }
}

class AppEntity {
  AppEntity(
    this.packageName,
    this.appName, {
    this.uid,
    this.apkPath = '',
    this.freeze = false,
  });
  final String packageName;
  String iconPath = '';
  String appName;
  final String apkPath;
  String targetSdk = '';
  String minSdk = '';
  String versionName = '';
  String versionCode = '';
  final bool freeze;
  final String uid;
  @override
  String toString() {
    return 'appName : $appName packageName : $packageName';
  }
}

class AppEntity {
  AppEntity(
    this.packageName,
    this.appName, {
    this.uid,
    this.apkPath = '',
    this.freeze = false,
    this.hide = false,
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
  @override
  String toString() {
    return 'appName : $appName packageName : $packageName';
  }

  @override
  bool operator ==(dynamic other) {
    // 判断是否是非
    if (other is! AppEntity) {
      return false;
    }
    if (other is AppEntity) {
      final AppEntity entity = other;
      return packageName == entity.packageName;
    }
    return false;
  }

  @override
  int get hashCode => packageName.hashCode;
}

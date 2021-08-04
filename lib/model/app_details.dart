class AppDetails {
  AppDetails({
    this.installTime,
    this.updateTime,
    this.apkSize,
    this.apkMd5,
    this.apkSha1,
    this.apkSha256,
    this.dataDir,
    this.libDir,
    this.activitys,
  });
  String installTime;
  String updateTime;
  String apkSize;
  String apkMd5;
  String apkSha1;
  String apkSha256;
  String dataDir;
  String libDir;
  List<String> activitys;
  List<SoEntity> soLibs;
}

class SoEntity {
  final String path;
  final String size;

  SoEntity(this.path, this.size);
}

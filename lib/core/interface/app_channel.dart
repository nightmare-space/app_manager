// app相关的抽象
import 'package:app_manager/model/app.dart';

abstract class AppChannel {
  Future<List<AppInfo>> getAppInfo(List<String> packages);

  Future<String> getAppDetails(String package);

  Future<List<String>> getAppActivitys(String package);

  Future<List<String>> getAppPermission(String package);

  Future<List<int>> getAppIconBytes(String packageName);
  
  Future<List<List<int>>> getAllAppIconBytes(List<String> packages);

  Future<String> getAppMainActivity(String packageName);

  Future<bool> clearAppData(String packageName);

  Future<bool> hideApp(String packageName);

  Future<bool> showApp(String packageName);

  Future<bool> freezeApp(String packageName);

  Future<bool> unFreezeApp(String packageName);

  Future<bool> unInstallApp(String packageName);

  Future<void> launchActivity(
    String packageName,
    String activity,
  );

  Future<String> getFileSize(String path);
}

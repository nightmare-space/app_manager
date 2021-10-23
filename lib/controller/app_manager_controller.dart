import 'dart:io';

import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

/// pm 命令
/// -U 显示 uid
/// -f 显示相关路径
/// -3 显示三方app
/// -u 显示已卸载的app
/// -d 只显示被禁用的app
class AppManagerController extends GetxController {
  //用户应用
  List<AppInfo> _userApps = <AppInfo>[];
  //系统应用
  List<AppInfo> _sysApps = <AppInfo>[];
  List<AppInfo> get userApps => _userApps;
  List<AppInfo> get sysApps => _sysApps;

  Future<void> getUserApp() async {
    _userApps = await AppUtils.getAllAppInfo(
      appChannel: Global().appChannel,
      executable: Global().process,
    );
    update();
    Log.w('_userApps length -> ${_userApps.length}');
  }

  Future<void> getSysApp() async {
    _sysApps = await AppUtils.getAllAppInfo(
      appType: AppType.system,
      appChannel: Global().appChannel,
      executable: Global().process,
    );
    update();
    Log.w('_sysApps length -> ${_userApps.length}');
  }

  // Future<void> cacheUserIcons() async {
  //   for (AppInfo entity in _userApps) {
  //     // Log.i('缓存 ${entity.packageName} 图标');
  //     // if (IconStore().loadCache(entity.packageName).isEmpty) {
  //     File cacheFile = File(
  //         RuntimeEnvir.filesPath + '/AppManager/.icon/${entity.packageName}');
  //     if (!await cacheFile.exists()) {
  //       await cacheFile.writeAsBytes(
  //         await Global().appChannel.getAppIconBytes(entity.packageName),
  //       );
  //     }
  //     // IconStore().cache(
  //     //   entity.packageName,
  //     //   await AppUtils.getAppIconBytes(entity.packageName),
  //     // );
  //     // }
  //   }
  // }

  // Future<void> cacheSysIcons() async {
  //   for (AppEntity entity in _sysApps) {
  //     // Log.i('缓存 ${entity.packageName} 图标');
  //     IconStore().cache(
  //       entity.packageName,
  //       await AppUtils.getAppIconBytes(entity.packageName),
  //     );
  //   }
  // }

  void removeEntity(AppInfo entity) {
    if (_userApps.contains(entity)) {
      _userApps.remove(entity);
    }
    if (_sysApps.contains(entity)) {
      _userApps.remove(entity);
    }
    update();
  }
}

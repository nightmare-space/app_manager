import 'dart:io';

import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

List<String> parsePMOut(String out) {
  String tmp = out.replaceAll(RegExp('package:'), '');
  return tmp.split('\n');
}

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
    Log.w('getUserApp');
    //拿到应用软件List
    Stopwatch watch = Stopwatch();
    watch.start();
    final List<AppInfo> entitys = <AppInfo>[];

    // 获取三方应用 -
    String defaultAppsResult = await Global().exec('pm list package -3 -f -U');
    Log.e('defaultAppsResult -> $defaultAppsResult');
    final List<String> defaultAppsList = parsePMOut(defaultAppsResult);
    // 这个比上面那个显示得更多，多显示被隐藏的app列表
    String result = await Global().exec('pm list package -3 -u -f -U');
    Log.e('watch -> ${watch.elapsed}');
    final List<String> resultList = parsePMOut(result);
    final List<String> packages = [];

    // 这个循环解析出被隐藏的app信息
    for (int i = 0; i < resultList.length; i++) {
      String uid = resultList[i].replaceAll(RegExp('.*uid:'), '');
      String packageName = resultList[i].replaceAll(
        RegExp('.*=| uid:$uid'),
        '',
      );
      String apkPath = resultList[i].replaceAll('=$packageName uid:$uid', '');
      packages.add(packageName);
      bool hide = false;
      // 如果所有的app里面没有这个app
      // 说明这个app是被隐藏的
      if (defaultAppsResult.isNotEmpty &&
          !defaultAppsList.contains(resultList[i])) {
        Log.e('packageName -> $packageName ${resultList[i]}');
        hide = true;
      }
      entitys.add(AppInfo(
        packageName,
        apkPath: apkPath,
        uid: uid,
        hide: hide,
      ));
    }
    // 获取三方被禁用(冻结)的app
    String disableApp = await Global().exec('pm list package -3 -d');
    List<String> disableAppList;
    if (disableApp.isNotEmpty) {
      // 有可能一个冻结的应用都没有
      disableAppList = parsePMOut(disableApp);
      Log.e('disableApp -> $disableAppList');
    }
    for (int i = 0; i < disableAppList.length; i++) {
      String packageName = disableAppList[i];

      try {
        // 如果
        AppInfo entity =
            entitys.firstWhere((element) => element.packageName == packageName);
        Log.w('entity -> $entity');
        entity.freeze = true;
      } catch (e) {
        // pass
      }
    }
    final List<AppInfo> infos = await Global().appChannel.getAppInfo(packages);
    if (infos.isEmpty) {
      return;
    }
    for (int i = 0; i < infos.length; i++) {
      entitys[i] = entitys[i].copyWith(infos[i]);
    }
    entitys.sort(
      (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
    );
    _userApps = entitys;
    update();
    cacheAllUserIcons(packages);

    Log.w('_userApps length -> ${_userApps.length}');
  }

  Future<void> getSysApp() async {
    //拿到应用软件List

    Log.w('getUserApp');
    //拿到应用软件List
    Stopwatch watch = Stopwatch();
    watch.start();
    final List<AppInfo> entitys = <AppInfo>[];

    Log.e('watch -> ${watch.elapsed}');
    // 获取三方应用 -
    String defaultAppsResult = await Global().exec('pm list package -s -f -U');
    Log.e('watch -> ${watch.elapsed}');
    final List<String> defaultAppsList = parsePMOut(defaultAppsResult);
    // 这个比上面那个显示得更多，多显示被隐藏的app列表
    String result = await Global().exec('pm list package -s -u -f -U');
    Log.e('watch -> ${watch.elapsed}');
    final List<String> resultList = parsePMOut(result);
    final List<String> packages = [];

    // 这个循环解析出被隐藏的app信息
    for (int i = 0; i < resultList.length; i++) {
      String uid = resultList[i].replaceAll(RegExp('.*uid:'), '');
      String packageName = resultList[i].replaceAll(
        RegExp('.*=| uid:$uid'),
        '',
      );
      String apkPath = resultList[i].replaceAll('=$packageName uid:$uid', '');
      packages.add(packageName);
      bool hide = false;
      // 如果所有的app里面没有这个app
      // 说明这个app是被隐藏的
      if (defaultAppsResult.isNotEmpty &&
          !defaultAppsList.contains(resultList[i])) {
        hide = true;
      }
      entitys.add(AppInfo(
        packageName,
        apkPath: apkPath,
        uid: uid,
        hide: hide,
      ));
    }
    Log.e('disableApp -> ${watch.elapsed}');
    // 获取三方被禁用(冻结)的app
    String disableApp = await Global().exec('pm list package -s -d');
    List<String> disableAppList;
    if (disableApp.isNotEmpty) {
      // 有可能一个冻结的应用都没有
      disableAppList = parsePMOut(disableApp);
    }
    for (int i = 0; i < disableAppList.length; i++) {
      String packageName = disableAppList[i];
      AppInfo entity;
      try {
        // 如果
        entitys.firstWhere((element) => element.packageName == packageName);
        entity.freeze = true;
      } catch (e) {
        // pass
      }
    }
    final List<AppInfo> infos = await Global().appChannel.getAppInfo(packages);
    if (infos.isEmpty) {
      return;
    }
    for (int i = 0; i < infos.length; i++) {
      entitys[i] = entitys[i].copyWith(infos[i]);
    }
    entitys.sort(
      (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
    );
    _sysApps = entitys;
    update();
    cacheAllUserIcons(packages);

    Log.w('_userApps length -> ${_userApps.length}');
  }

  Future<void> cacheUserIcons() async {
    for (AppInfo entity in _userApps) {
      // Log.i('缓存 ${entity.packageName} 图标');
      // if (IconStore().loadCache(entity.packageName).isEmpty) {
      File cacheFile = File(
          RuntimeEnvir.filesPath + '/AppManager/.icon/${entity.packageName}');
      if (!await cacheFile.exists()) {
        await cacheFile.writeAsBytes(
          await Global().appChannel.getAppIconBytes(entity.packageName),
        );
      }
      // IconStore().cache(
      //   entity.packageName,
      //   await AppUtils.getAppIconBytes(entity.packageName),
      // );
      // }
    }
  }

  // 根据文件头将一维数组缓拆分成二维数组
  Future<void> cacheAllUserIcons(List<String> packages) async {
    // 所有图
    final List<List<int>> byteList =
        await Global().appChannel.getAllAppIconBytes(packages);
    // Log.e('allBytes -> $allBytes');
    if (byteList.isEmpty) {
      return;
    }
    Log.w('缓存全部...');

    for (int i = 0; i < packages.length; i++) {
      String cachePath =
          '${RuntimeEnvir.filesPath}/AppManager/.icon/${packages[i]}';
      File cacheFile = File(cachePath);
      if (!(await cacheFile.exists())) {
        await cacheFile.writeAsBytes(
          byteList[i],
        );
      }
    }
  }

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

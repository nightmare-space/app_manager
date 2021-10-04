import 'dart:io';

import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

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

    Log.e('watch -> ${watch.elapsed}');
    String defaultAppsResult = await Global().exec('pm list package -3 -f -U');
    Log.e('watch -> ${watch.elapsed}');
    defaultAppsResult = defaultAppsResult.replaceAll(RegExp('package:'), '');
    final List<String> defaultAppsList = defaultAppsResult.split('\n');
    Log.e(defaultAppsList);
    String result = await Global().exec('pm list package -3 -u -f -U');
    Log.e('watch -> ${watch.elapsed}');
    result = result.replaceAll(RegExp('package:'), '');
    final List<String> resultList = result.split('\n');
    // 获取第三方的冻结应用

    final List<String> packages = [];
    for (int i = 0; i < resultList.length; i++) {
      String uid = resultList[i].replaceAll(RegExp('.*uid:'), '');
      String packageName = resultList[i].replaceAll(
        RegExp('.*=| uid:$uid'),
        '',
      );
      String apkPath = resultList[i].replaceAll('=$packageName uid:$uid', '');
      packages.add(packageName);
      bool hide = false;
      if (!defaultAppsList.contains(resultList[i])) {
        hide = true;
      }
      // Log.w('包名 -> $packageName apkPath -> $apkPath');
      entitys.add(AppInfo(
        packageName,
        apkPath: apkPath,
        uid: uid,
        hide: hide,
      ));
    }
    Log.e('disableApp -> ${watch.elapsed}');
    String disableApp = await Global().exec('pm list package -3 -d');
    Log.e('disableApp -> ${watch.elapsed}');
    disableApp = disableApp.replaceAll(RegExp('package:'), '');
    Log.e("disableApp -> $disableApp");
    final List<String> disableAppList = [];
    if (disableApp.isNotEmpty) {
      // 有可能一个冻结的应用都没有
      disableAppList.addAll(disableApp.split('\n'));
    }
    for (int i = 0; i < disableAppList.length; i++) {
      String packageName = disableAppList[i];
      // Log.w('包名 -> $packageName apkPath -> $apkPath');
      AppInfo entity;
      try {
        entitys.firstWhere((element) => element.packageName == packageName);
        entity.freeze = true;
      } catch (e) {}
    }
    Log.e('watch -> ${watch.elapsed}');
    final List<AppInfo> infos = await AppUtils.getAppInfo(packages);
    Log.e('watch -> ${watch.elapsed}');
    if (infos.isEmpty) {
      return;
    }
    for (int i = 0; i < infos.length; i++) {
      entitys[i] = entitys[i].copyWith(infos[i]);
    }
    entitys.sort(
        (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    // saveImg(yylist);
    // Log.e(await Global().process.exec('pm list package -3 -f'));
    _userApps = entitys;
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
          await AppUtils.getAppIconBytes(entity.packageName),
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
        await AppUtils.getAllAppIconBytes(packages);
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

  Future<void> getSysApp() async {
    //拿到应用软件List
    final List<AppInfo> entitys = <AppInfo>[];

    final List<String> resultList =
        (await Global().exec('pm list package -s -f -U'))
            .replaceAll(RegExp('package:'), '')
            .split('\n');
    // print(resultList);
    final List<String> packages = [];
    for (int i = 0; i < resultList.length; i++) {
      String uid = resultList[i].replaceAll(RegExp('.*uid:'), '');
      // Log.w('$uid');
      String packageName = resultList[i].replaceAll(
        RegExp('.*=| uid:$uid'),
        '',
      );
      String apkPath = resultList[i].replaceAll('=$packageName uid:$uid', '');
      packages.add(packageName);
      // Log.w('包名 -> $packageName apkPath -> $apkPath');
      entitys.add(AppInfo(packageName, apkPath: apkPath, uid: uid));
    }
    final List<AppInfo> infos = await AppUtils.getAppInfo(packages);
    if (infos.isEmpty) {
      return;
    }
    for (int i = 0; i < infos.length; i++) {
      entitys[i] = entitys[i].copyWith(infos[i]);
    }
    entitys.sort(
        (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    // saveImg(yylist);
    // Log.e(await Global().process.exec('pm list package -3 -f'));
    _sysApps = entitys;
    // cacheSysIcons();
    update();
  }

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

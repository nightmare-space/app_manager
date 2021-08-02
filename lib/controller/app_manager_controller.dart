import 'dart:io';

import 'package:app_manager/global/global.dart';
import 'package:app_manager/global/icon_store.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:app_manager/utils/socket_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class AppManagerController extends GetxController {
  //用户应用
  List<AppEntity> _userApps = <AppEntity>[];
  //系统应用
  List<AppEntity> _sysApps = <AppEntity>[];
  List<AppEntity> get userApps => _userApps;
  List<AppEntity> get sysApps => _sysApps;

  Future<void> getUserApp() async {
    //拿到应用软件List
    Stopwatch watch = Stopwatch();
    watch.start();
    final List<AppEntity> entitys = <AppEntity>[];

    String defaultAppsResult = await Global().exec('pm list package -3 -f -U');
    Log.e('watch -> ${watch.elapsed}');
    defaultAppsResult = defaultAppsResult.replaceAll(RegExp('package:'), '');
    final List<String> defaultAppsList = defaultAppsResult.split('\n');
    // Log.e(defaultAppsList);
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
      entitys.add(
          AppEntity(packageName, '', apkPath: apkPath, uid: uid, hide: hide));
    }
    Log.e('disableApp -> ${watch.elapsed}');
    String disableApp = await Global().exec('pm list package -3 -d');
    Log.e('disableApp -> ${watch.elapsed}');
    disableApp = disableApp.replaceAll(RegExp('package:'), '');
    // Log.e("disableApp -> $disableApp");
    final List<String> disableAppList = [];
    if (disableApp.isNotEmpty) {
      // 有可能一个冻结的应用都没有
      disableAppList.addAll(disableApp.split('\n'));
    }
    for (int i = 0; i < disableAppList.length; i++) {
      String packageName = disableAppList[i];
      // Log.w('包名 -> $packageName apkPath -> $apkPath');
      AppEntity entity =
          entitys.firstWhere((element) => element.packageName == packageName);
      entity.freeze = true;
    }
    Log.e('watch -> ${watch.elapsed}');
    final List<String> infos = await AppUtils.getAppInfo(packages);
    Log.e('watch -> ${watch.elapsed}');
    if (infos.isEmpty) {
      return;
    }
    // Log.e('infos -> $infos');
    for (int i = 0; i < infos.length; i++) {
      List<String> infoList = infos[i].split('\r');
      entitys[i].appName = infoList[0];
      entitys[i].minSdk = infoList[1];
      entitys[i].targetSdk = infoList[2];
      entitys[i].versionName = infoList[3];
      entitys[i].versionCode = infoList[4];
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
    for (AppEntity entity in _userApps) {
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
    List<int> allBytes = await AppUtils.getAllAppIconBytes(packages);
    // Log.e('allBytes -> $allBytes');
    if (allBytes.isEmpty) {
      return;
    }
    Log.w('缓存全部...');
    List<List<int>> byteList = [];
    byteList.length = packages.length;
    int index = 0;
    for (int i = 0; i < allBytes.length; i++) {
      byteList[index] ??= [];
      byteList[index].add(allBytes[i]);
      if (i < allBytes.length - 1 - 6 &&
          allBytes[i + 1] == 137 &&
          allBytes[i + 2] == 80 &&
          allBytes[i + 3] == 78 &&
          allBytes[i + 4] == 71 &&
          allBytes[i + 5] == 13 &&
          allBytes[i + 6] == 10 &&
          i != 0) {
        index++;
        // Log.w('缓存第$index个包名的');
      }
    }
    for (int i = 0; i < packages.length; i++) {
      File cacheFile =
          File(RuntimeEnvir.filesPath + '/AppManager/.icon/${packages[i]}');
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
    final List<AppEntity> entitys = <AppEntity>[];

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
      entitys.add(AppEntity(packageName, '', apkPath: apkPath, uid: uid));
    }
    final List<String> infos = await AppUtils.getAppInfo(packages);

    for (int i = 0; i < infos.length; i++) {
      List<String> infoList = infos[i].split('\r');
      entitys[i].appName = infoList[0];
      entitys[i].minSdk = infoList[1];
      entitys[i].targetSdk = infoList[2];
      entitys[i].versionName = infoList[3];
      entitys[i].versionCode = infoList[4];
    }
    entitys.sort(
        (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    // saveImg(yylist);
    // Log.e(await Global().process.exec('pm list package -3 -f'));
    _sysApps = entitys;
    // cacheSysIcons();
    update();
  }

  void removeEntity(AppEntity entity) {
    if (_userApps.contains(entity)) {
      _userApps.remove(entity);
    }
    if (_sysApps.contains(entity)) {
      _userApps.remove(entity);
    }
    update();
  }
}

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
    final List<AppEntity> entitys = <AppEntity>[];
    String result = await Global().exec('pm list package -3 -e -f -U');
    result = result.replaceAll(RegExp('package:'), '');
    final List<String> resultList = result.split('\n');
    String disableApp = await Global().exec('pm list package -3 -d -f -U');
    Log.e("disableApp -> $disableApp");
    disableApp = disableApp.replaceAll(RegExp('package:'), '');
    final List<String> disableAppList = [];
    if (disableApp.isNotEmpty) {
      // 有可能一个冻结的应用都没有
      disableAppList.addAll(disableApp.split('\n'));
    }
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
    for (int i = 0; i < disableAppList.length; i++) {
      String uid = disableAppList[i].replaceAll(RegExp('.*uid:'), '');
      String packageName = disableAppList[i].replaceAll(
        RegExp('.*=| uid:$uid'),
        '',
      );
      String apkPath = disableAppList[i].replaceAll('=$packageName', '');
      packages.add(packageName);
      // Log.w('包名 -> $packageName apkPath -> $apkPath');
      entitys.add(AppEntity(
        packageName,
        '',
        apkPath: apkPath,
        freeze: true,
        uid: uid,
      ));
    }
    final List<String> infos = await AppUtils.getAppInfo(packages);
    if (infos.isEmpty) {
      return;
    }
    Log.e('infos -> $infos');
    for (int i = 0; i < infos.length; i++) {
      List<String> infoList = infos[i].split(' ');
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
    if (AppUtils.runOnPackage()) {
      cacheAllUserIcons(packages);
    } else {
      cacheUserIcons();
    }
    Log.w('_userApps length -> ${_userApps.length}');
  }

  Future<void> cacheUserIcons() async {
    for (AppEntity entity in _userApps) {
      // Log.i('缓存 ${entity.packageName} 图标');
      if (IconStore().loadCache(entity.packageName).isEmpty) {
        IconStore().cache(
          entity.packageName,
          await AppUtils.getAppIconBytes(entity.packageName),
        );
      }
    }
  }

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
        Log.w('缓存第$index个包名的');
      }
    }
    for (int i = 0; i < packages.length; i++) {
      IconStore().cache(packages[i], byteList[i]);
      if (packages[i] == 'com.taxis99') {
        final filePath = RuntimeEnvir.binPath + '/placeholder.png';
        final File file = File(filePath);
        if (!await file.exists()) {
          await file.writeAsBytes(byteList[i]);
        }
      }
    }
  }

  Future<void> cacheSysIcons() async {
    for (AppEntity entity in _sysApps) {
      // Log.i('缓存 ${entity.packageName} 图标');
      IconStore().cache(
        entity.packageName,
        await AppUtils.getAppIconBytes(entity.packageName),
      );
    }
  }

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
      List<String> infoList = infos[i].split(' ');
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
}

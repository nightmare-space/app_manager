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
    String result = await Global().process.exec('pm list package -3 -e -f -U');
    result = result.replaceAll(RegExp('package:'), '');
    final List<String> resultList = result.split('\n');

    String disableApp =
        await Global().process.exec('pm list package -3 -d -f -U');
    disableApp = disableApp.replaceAll(RegExp('package:'), '');
    final List<String> disableAppList = disableApp.split('\n');
    Log.e(disableApp);
    final List<String> packages = [];
    for (int i = 0; i < resultList.length; i++) {
      String uid = resultList[i].replaceAll(RegExp('.*uid:'), '');
      // Log.w('$uid');
      String packageName = resultList[i].replaceAll(
        RegExp('.*=| uid:$uid'),
        '',
      );
      String apkPath = resultList[i].replaceAll('=$packageName', '');
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
        (await Global().process.exec('pm list package -s -f -U'))
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
      String apkPath = resultList[i].replaceAll('=$packageName', '');
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
    update();
  }
}

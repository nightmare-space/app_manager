import 'dart:io';

import 'package:app_manager/core/interface/app_channel.dart';
import 'package:app_manager/global/config.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/socket_util.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

const MethodChannel _channel = MethodChannel('app_manager');
int port = 6000;
enum AppType {
  user,
  system,
}

// 根据文件头将一维数组缓拆分成二维数组
Future<void> cacheAllUserIcons(
  List<String> packages,
  AppChannel appChannel,
) async {
  // 所有图
  final List<List<int>> byteList =
      await appChannel.getAllAppIconBytes(packages);
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

List<String> parsePMOut(String out) {
  String tmp = out.replaceAll(RegExp('package:'), '');
  return tmp.split('\n');
}

class AppUtils {
  static Future<List<AppInfo>> getAllAppInfo({
    AppType appType = AppType.user,
    Executable executable,
    AppChannel appChannel,
  }) async {
    String option = '-3';
    if (appType == AppType.system) {
      option = '-s';
    }
    Log.w('getUserApp');
    //拿到应用软件List
    Stopwatch watch = Stopwatch();
    watch.start();
    final List<AppInfo> entitys = <AppInfo>[];

    // 获取三方应用 -
    String defaultAppsResult =
        await executable.exec('pm list package $option -f -U');
    Log.e('defaultAppsResult -> $defaultAppsResult');
    final List<String> defaultAppsList = parsePMOut(defaultAppsResult);
    // 这个比上面那个显示得更多，多显示被隐藏的app列表
    String result = await executable.exec('pm list package $option -u -f -U');
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
    String disableApp = await executable.exec('pm list package $option -d');
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
    final List<AppInfo> infos = await appChannel.getAppInfo(packages);
    if (infos.isEmpty) {
      return [];
    }
    for (int i = 0; i < infos.length; i++) {
      entitys[i] = entitys[i].copyWith(infos[i]);
    }
    entitys.sort(
      (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
    );
    cacheAllUserIcons(packages, appChannel);
    return entitys;
  }
}

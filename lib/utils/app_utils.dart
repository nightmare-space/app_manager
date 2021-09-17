import 'dart:io';

import 'package:app_manager/global/config.dart';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/socket_util.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

const MethodChannel _channel = MethodChannel('app_manager');
int port = 6000;

class AppUtils {
  static bool runOnPackage() {
    return RuntimeEnvir.packageName != Config.packageName;
  }

  static Future<List<AppInfo>> getAppInfo(List<String> packages) async {
    if (runOnPackage()) {
      port = 6001;
    }
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    // Log.w('等待连接');
    await manager.connect();
    // Log.w('连接成功');
    manager.sendMsg('getAllAppInfo ' + packages.join(' ') + '\n');
    final List<String> infos = (await manager.getString()).split('\n');
    infos.removeLast();
    // Log.e('infos -> $infos');
    final List<AppInfo> entitys = <AppInfo>[];
    for (int i = 0; i < infos.length; i++) {
      List<String> infoList = infos[i].split('\r');
      final AppInfo appInfo = AppInfo(
        packages[i],
        appName: infoList[0],
        minSdk: infoList[1],
        targetSdk: infoList[2],
        versionCode: infoList[4],
        versionName: infoList[3],
      );
      entitys.add(appInfo);
    }
    return entitys;
  }

  static Future<String> getAppDetails(String package) async {
    if (runOnPackage()) {
      port = 6001;
    }
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    // Log.w('等待连接');
    await manager.connect();
    // Log.w('连接成功');
    manager.sendMsg('getAppDetail ' + package + '\n');
    final String result = (await manager.getString());
    return result;
  }

  static Future<List<String>> getAppActivitys(String package) async {
    if (runOnPackage()) {
      port = 6001;
    }
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    // Log.w('等待连接');
    await manager.connect();
    // Log.w('连接成功');
    manager.sendMsg('getAppActivity ' + package + '\n');
    final List<String> infos = (await manager.getString()).split('\n');
    infos.removeLast();
    return infos;
  }

  static Future<List<String>> getAppPermission(String package) async {
    if (runOnPackage()) {
      port = 6001;
    }
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    // Log.w('等待连接');
    await manager.connect();
    // Log.w('连接成功');
    manager.sendMsg('getAppPermissions ' + package + '\n');
    final List<String> infos = (await manager.getString()).split('\r');
    infos.removeLast();
    return infos;
  }

  static Future<List<int>> getAppIconBytes(String packageName) async {
    if (runOnPackage()) {
      // 有意义
      port = 6001;
    }
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    await manager.connect();
    manager.sendMsg('getIconData ' '$packageName\n');
    List<int> result = await manager.getResult();

    // Log.w(result);
    return result;
  }

  static Future<List<List<int>>> getAllAppIconBytes(
      List<String> packages) async {
    if (runOnPackage()) {
      port = 6001;
    }
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    await manager.connect();
    manager.sendMsg('getAllIconData ' + packages.join(' ') + '\n');
    List<int> allBytes = await manager.getResult();
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
    // Log.w(result);
    return byteList;
  }

  static Future<String> getAppMainActivity(String packageName) async {
    final String activityName =
        await _channel.invokeMethod<String>('getMainActivity', packageName);
    return activityName;
  }

  static Future<bool> clearAppData(String packageName) async {
    String result = await Global().exec('pm clear $packageName');
    return result.isNotEmpty;
  }

  static Future<bool> hideApp(String packageName) async {
    String result = await Global().exec('pm hide $packageName');
    return result.isNotEmpty;
  }

  static Future<bool> showApp(String packageName) async {
    String result = await Global().exec('pm unhide $packageName');
    return result.isNotEmpty;
  }

  static Future<bool> freezeApp(String packageName) async {
    Log.i('pm disable $packageName');
    String result =
        await Global().exec('pm disable-user --user 0 $packageName');
    return result.isNotEmpty;
  }

  static Future<bool> unFreezeApp(String packageName) async {
    String result = await Global().exec('pm enable --user 0 $packageName');
    return result.isNotEmpty;
  }

  static Future<bool> unInstallApp(String packageName) async {
    String result = await Global().exec('pm uninstall  $packageName');
    return result.isNotEmpty;
  }

  static Future<void> launchActivity(
    String packageName,
    String activity,
  ) async {
    if (runOnPackage()) {
      await Global().exec('am start -n $packageName/$activity');
      return;
    }
    const MethodChannel jump = MethodChannel('jump');
    jump.invokeMethod(
      [
        packageName,
        activity,
      ].join('\n'),
    );
  }

  static Future<String> getFileSize(String path) async {
    return await Global().exec('stat -c "%s" $path');
  }
}

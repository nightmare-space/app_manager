import 'dart:io';

import 'package:app_manager/global/config.dart';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/utils/socket_util.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

const MethodChannel _channel = MethodChannel('app_manager');

class AppUtils {
  static bool runOnPackage() {
    return RuntimeEnvir.packageName != Config.packageName;
  }

  static Future<List<String>> getAppInfo(List<String> packages) async {
    if (runOnPackage()) {
      SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, 4041);
      // Log.w('等待连接');
      await manager.connect();
      // Log.w('连接成功');
      manager.sendMsg('getAppInfo ' + packages.join(' ') + '\n');
      final List<String> infos = (await manager.getString()).split('\n');
      infos.removeLast();
      return infos;
    } else {
      String result = await _channel.invokeMethod<String>(
        'getAppInfo',
        packages.join(' '),
      );
      List<String> infos = result.split('\n');
      infos.removeLast();
      return infos;
    }
  }

  static Future<List<int>> getAppIconBytes(String packageName) async {
    if (runOnPackage()) {
      SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, 4041);
      await manager.connect();
      manager.sendMsg('getIconData ' '$packageName\n');
      List<int> result = await manager.getResult();
      // Log.w(result);
      return result;
    } else {
      return await _channel.invokeMethod<List<int>>('getAppIcon', packageName);
    }
  }

  static Future<List<int>> getAllAppIconBytes(List<String> packages) async {
    if (runOnPackage()) {
      Log.w('runOnPackagerunOnPackagerunOnPackagerunOnPackagerunOnPackage');
      SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, 4041);
      await manager.connect();
      manager.sendMsg('getAllIconData ' + packages.join(' ')+'\n');
      List<int> result = await manager.getResult();
      // Log.w(result);
      return result;
    } else {
      return [];
    }
  }

  static Future<String> getAppMainActivity(String packageName) async {
    const MethodChannel getAppIcon = MethodChannel('GetAppInfo');
    final String activityName = await getAppIcon.invokeMethod<String>(
      packageName,
    );
    return activityName;
  }

  static Future<void> hideApp(String packageName) async {
    Log.w(await Global().exec('pm hide $packageName'));
  }

  static Future<bool> freezeApp(String packageName) async {
    Log.i('pm disable $packageName');
    String result =
        await Global().exec('pm disable-user --user 0 $packageName');
    return result.isNotEmpty;
  }

  static Future<void> unFreezeApp(String packageName) async {
    Log.w(await Global().exec('pm enable $packageName'));
  }
}

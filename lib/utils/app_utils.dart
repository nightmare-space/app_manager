import 'dart:io';

import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/platform_channel.dart';
import 'package:app_manager/utils/socket_util.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

const MethodChannel _channel = MethodChannel('GetAppIcon');

class AppUtils {
  static Future<List<String>> getAppInfo(List<String> packages) async {
    SocketWrapper manager = SocketWrapper(
      InternetAddress.anyIPv4,
      4042,
    );
    Log.w('等待连接');
    await manager.connect();
    manager.sendMsg(packages.join(' ') + '\n');
    final List<String> infos = (await manager.getString()).split('\n');
    infos.removeLast();
    return infos;
  }

  static Future<List<int>> getAppIconBytes(String packageName) async {
    // return _channel.invokeMethod<List<int>>(packageName);
    SocketWrapper manager = SocketWrapper(
      InternetAddress.anyIPv4,
      4041,
    );
    await manager.connect();
    manager.sendMsg('$packageName\n');
    // List<int> result = await manager.mStream.;
    return await manager.getResult();
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

  static Future<void> freezeApp(String packageName) async {
    Log.w(await Global().exec('pm disable $packageName'));
  }
}

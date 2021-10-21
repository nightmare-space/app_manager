import 'dart:io';

import 'package:app_manager/core/foundation/protocol.dart';
import 'package:app_manager/core/interface/app_channel.dart';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/socket_util.dart';
import 'package:global_repository/global_repository.dart';

class LocalAppChannel implements AppChannel {
  int port = 6000;
  @override
  Future<List<AppInfo>> getAppInfo(List<String> packages) async {
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    Log.w('等待连接');
    await manager.connect();
    Log.w('连接成功');
    manager.sendMsg(Protocol.getAllAppInfo + packages.join(' ') + '\n');
    final List<String> infos = (await manager.getString()).split('\n');
    infos.removeLast();
    Log.e('infos -> $infos');
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

  @override
  Future<String> getAppDetails(String package) async {
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    // Log.w('等待连接');
    await manager.connect();
    // Log.w('连接成功');
    manager.sendMsg(Protocol.getAppDetail + package + '\n');
    final String result = (await manager.getString());
    return result;
  }

  @override
  Future<List<String>> getAppActivitys(String package) async {
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    // Log.w('等待连接');
    await manager.connect();
    // Log.w('连接成功');
    manager.sendMsg(Protocol.getAppActivity + package + '\n');
    final List<String> infos = (await manager.getString()).split('\n');
    infos.removeLast();
    return infos;
  }

  @override
  Future<List<String>> getAppPermission(String package) async {
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    // Log.w('等待连接');
    await manager.connect();
    // Log.w('连接成功');
    manager.sendMsg(Protocol.getAppPermissions + package + '\n');
    final List<String> infos = (await manager.getString()).split('\r');
    infos.removeLast();
    return infos;
  }

  @override
  Future<List<int>> getAppIconBytes(String packageName) async {
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    await manager.connect();
    manager.sendMsg(Protocol.getIconData + '$packageName\n');
    List<int> result = await manager.getResult();
    // Log.w(result);
    return result;
  }

  @override
  Future<List<List<int>>> getAllAppIconBytes(List<String> packages) async {
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    await manager.connect();
    manager.sendMsg(Protocol.getAllIconData + packages.join(' ') + '\n');
    List<int> allBytes = await manager.getResult();
    List<List<int>> byteList = [];
    byteList.length = packages.length;
    int index = 0;
    // 根据png编码的头对图片进行拆分
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

  @override
  Future<String> getAppMainActivity(String packageName) async {
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    manager.sendMsg(Protocol.getAppMainActivity + packageName + '\n');
    await manager.connect();
    final String result = (await manager.getString());
    return result;
  }

  @override
  Future<bool> clearAppData(String packageName) async {
    String result = await Global().exec('pm clear $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<bool> hideApp(String packageName) async {
    String result = await Global().exec('pm hide $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<bool> showApp(String packageName) async {
    String result = await Global().exec('pm unhide $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<bool> freezeApp(String packageName) async {
    Log.i('pm disable $packageName');
    String result = await Global().exec(
      'pm disable-user --user 0 $packageName',
    );
    return result.isNotEmpty;
  }

  @override
  Future<bool> unFreezeApp(String packageName) async {
    String result = await Global().exec('pm enable --user 0 $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<bool> unInstallApp(String packageName) async {
    String result = await Global().exec('pm uninstall  $packageName');
    return result.isNotEmpty;
  }

  @override
  Future<void> launchActivity(
    String packageName,
    String activity,
  ) async {
    // if (runOnPackage()) {
    //   await Global().exec('am start -n $packageName/$activity');
    //   return;
    // }
    // const MethodChannel jump = MethodChannel('jump');
    // jump.invokeMethod(
    //   [
    //     packageName,
    //     activity,
    //   ].join('\n'),
    // );
  }

  @override
  Future<String> getFileSize(String path) async {
    return await Global().exec('stat -c "%s" $path');
  }
}

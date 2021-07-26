import 'dart:io';

import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/platform_channel.dart';
import 'package:app_manager/utils/socket_util.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

const MethodChannel _channel = MethodChannel('GetAppIcon');

class AppUtils {
  static Future<List<AppEntity>> getUserApps() async {
    //拿到应用软件List
    final List<AppEntity> entitys = <AppEntity>[];

    final List<String> resultList =
        (await Global().process.exec('pm list package -3 -f'))
            .replaceAll(RegExp('package:'), '')
            .split('\n');
    // print(resultList);
    final List<String> packages = [];
    for (int i = 0; i < resultList.length; i++) {
      String packageName = resultList[i].replaceAll(RegExp('.*='), '');
      String apkPath = resultList[i].replaceAll('=$packageName', '');
      packages.add(packageName);
      // Log.w('包名 -> $packageName apkPath -> $apkPath');
      entitys.add(AppEntity(packageName, '', apkPath: apkPath));
    }
    NetworkManager manager = NetworkManager(
      InternetAddress.anyIPv4,
      4042,
    );
    Log.w('等待连接');
    await manager.connect();
    manager.sendMsg(packages.join(' ') + '\n');
    final List<String> infos = (await manager.getString()).split('\n');
    // final List<String> infos =
    //     (await PlatformChannel.AppInfo.invokeMethod<String>(
    //             packages.join('\n')))
    //         .split('\n');
    infos.removeLast();
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
    return entitys;
  }



  static Future<List<AppEntity>> getSysApps() async {
    //拿到应用软件List
    final List<AppEntity> entitys = <AppEntity>[];

    final List<String> resultList =
        (await Global().process.exec('pm list package -s -f'))
            .replaceAll(RegExp('package:'), '')
            .split('\n');
    // print(resultList);
    final List<String> packages = [];
    for (int i = 0; i < resultList.length; i++) {
      String packageName = resultList[i].replaceAll(RegExp('.*='), '');
      String apkPath = resultList[i].replaceAll('=$packageName', '');
      packages.add(packageName);
      // Log.w('包名 -> $packageName apkPath -> $apkPath');
      entitys.add(AppEntity(packageName, '', apkPath: apkPath));
    }

    NetworkManager manager = NetworkManager(
      InternetAddress.anyIPv4,
      4042,
    );
    await manager.connect();

    manager.sendMsg(packages.join(' ') + '\n');
    final List<String> infos = (await manager.getString()).split('\n');
    infos.removeLast();
    for (int i = 0; i < infos.length; i++) {
      List<String> infoList = infos[i].split(' ');
      entitys[i].appName = infoList[0];
      entitys[i].minSdk = infoList[1];
      entitys[i].targetSdk = infoList[2];
      entitys[i].versionName = infoList[3];
      entitys[i].versionCode = infoList[4];
    }
    // saveImg(yylist);
    // Log.e(await Global().process.exec('pm list package -3 -f'));
    return entitys;
  }

  static Future<List<int>> loadAppIcon(String packageName) async {
    // return _channel.invokeMethod<List<int>>(packageName);
    NetworkManager manager = NetworkManager(
      InternetAddress.anyIPv4,
      4041,
    );
    await manager.connect();
    manager.sendMsg('$packageName\n');
    // List<int> result = await manager.mStream.;
    return await manager.getResult();
  }
}

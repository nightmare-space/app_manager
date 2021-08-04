import 'dart:io';

import 'package:app_manager/global/config.dart';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/utils/socket_util.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

const MethodChannel _channel = MethodChannel('app_manager');
// Future<void> getAppInfoByIsolate(List<String> packages) async {
//   ReceivePort receivePort = ReceivePort();
//   await Isolate.spawn(echo, receivePort.sendPort);
//   Stream<dynamic> stream = receivePort.asBroadcastStream();
//   // 'echo'发送的第一个message，是它的SendPort
//   SendPort sendPort;
//   await for (dynamic msg in stream) {
//     if (sendPort == null) {
//       sendPort = msg;
//       sendPort.send(packages);
//     } else {
//       String data = msg;
//       Log.w('第一个isolate收到消息:$data');
//     }
//   }
// }

// // 新isolate的入口函数
// echo(SendPort sendPort) async {
//   // 实例化一个ReceivePort 以接收消息
//   ReceivePort port = ReceivePort();

//   // 把它的sendPort发送给宿主isolate，以便宿主可以给它发送消息
//   sendPort.send(port.sendPort);

//   // 监听消息
//   await for (var msg in port) {
//     const MethodChannel _channel = MethodChannel('app_manager');
//     _channel.invokeMethod<String>(
//       'getAppInfo',
//       msg,
//     );
//     sendPort.send('hello');
//   }
// }
int port = 6000;

class AppUtils {
  static bool runOnPackage() {
    return RuntimeEnvir.packageName != Config.packageName;
  }

  static Future<List<String>> getAppInfo(List<String> packages) async {
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
    return infos;
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

  static Future<List<int>> getAllAppIconBytes(List<String> packages) async {
    if (runOnPackage()) {
      port = 6001;
    }
    SocketWrapper manager = SocketWrapper(InternetAddress.anyIPv4, port);
    await manager.connect();
    manager.sendMsg('getAllIconData ' + packages.join(' ') + '\n');
    List<int> result = await manager.getResult();
    // Log.w(result);
    return result;
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
      String packageName, String activity) async {
    const MethodChannel jump = MethodChannel('jump');
    jump.invokeMethod(
      [
        packageName,
        activity,
      ].join('\n'),
    );
  }
}

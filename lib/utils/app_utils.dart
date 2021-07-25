import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/platform_channel.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

const MethodChannel _channel = MethodChannel('GetAppIcon');

class AppUtils {
  static Future<List<AppEntity>> getUserApps() async {
    //拿到应用软件List
    final List<AppEntity> tmp = <AppEntity>[];
    final List<String> packageNames =
        (await Global().process.exec('pm list package -3'))
            .replaceAll(RegExp('package:'), '')
            .split('\n');
    final List<String> appNames =
        (await PlatformChannel.AppInfo.invokeMethod<String>(
                packageNames.join('\n')))
            .split('\n');
    for (int i = 0; i < packageNames.length; i++) {
      tmp.add(AppEntity(packageNames[i], appNames[i]));
    }
    tmp.forEach((element) {
      Log.w(element);
    });
    // saveImg(yylist);
    return tmp;
  }

  static Future<void> saveImg(List<String> map) async {
    for (final String a in map) {
      {
        await PlatformChannel.GetAppIcon.invokeMethod<void>(a);
      }
    }
  }

  static Future<List<AppEntity>> getSysApps() async {
    //拿到应用软件List
    final List<AppEntity> tmp = <AppEntity>[];
    final List<String> packageNames =
        (await YanProcess().exec('pm list package -s'))
            .replaceAll(RegExp('package:'), '')
            .split('\n');
    final List<String> appNames =
        (await PlatformChannel.AppInfo.invokeMethod<String>(
                packageNames.join('\n')))
            .split('\n');
    for (int i = 0; i < packageNames.length; i++) {
      tmp.add(AppEntity(packageNames[i], appNames[i]));
    }
    return tmp;
    // if (eventBus != null) eventBus.fire(YingYong1());
  }

  static Future<List<int>> loadAppIcon(String packageName) async {
    return _channel.invokeMethod<List<int>>(packageName);
  }
}

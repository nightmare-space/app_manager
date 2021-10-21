import 'package:app_manager/core/implement/local_app_channel.dart';
import 'package:app_manager/core/implement/remote_app_channel.dart';
import 'package:app_manager/core/interface/app_channel.dart';
import 'package:app_manager/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'config.dart';

class Global {
  // 工厂模式

  factory Global() => _getInstance();
  Global._internal() {
    if (RuntimeEnvir.packageName != Config.packageName) {
      // 如果这个项目是独立运行的，那么RuntimeEnvir.packageName会在main函数中被设置成Config.packageName
      Config.flutterPackage = Config.flutterPackagePrifix;
      Get.addPages(AppPages.routes);

      appChannel = RemoteAppChannel();
    } else {
      appChannel = LocalAppChannel();
    }
  }

  static Global get instance => _getInstance();

  static Global _instance;

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  AppChannel appChannel;
  Map<String, List<int>> iconCacheMap = {};
  YanProcess process = YanProcess();
  Future<void> initProcess() async {
    // TODO
    // await process.exec('su');
  }

  Future<String> exec(String script) {
    return process.exec(script);
  }
}

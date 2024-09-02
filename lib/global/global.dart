import 'package:app_channel/app_channel.dart';
import 'package:app_manager/bindings/app_manager_binding.dart';
import 'package:app_manager/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
// import 'package:app_channel/app_channel.dart';

import 'config.dart';

class Global {
  factory Global() => _getInstance()!;
  Global._internal() {
    if (RuntimeEnvir.packageName != Config.packageName) {
      // 如果这个项目是独立运行的，那么RuntimeEnvir.packageName会在main函数中被设置成Config.packageName
      Config.flutterPackage = Config.flutterPackagePrifix;
      Get.addPages(AppPages.routes);
      // 避免没有注册到依赖
      AppManagerBinding().dependencies();
    } else {}
  }

  static Global? get instance => _getInstance();

  static Global? _instance;

  static Global? _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  AppChannel? appChannel;
  Map<String, List<int>> iconCacheMap = {};
  YanProcess? process = YanProcess();

  Future<String> exec(String script) {
    return process!.exec(script);
  }
}

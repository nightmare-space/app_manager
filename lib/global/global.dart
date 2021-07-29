import 'package:global_repository/global_repository.dart';

class Global {
  // 工厂模式

  factory Global() => _getInstance();
  Global._internal();

  static Global get instance => _getInstance();

  static Global _instance;

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  Map<String, List<int>> iconCacheMap = {};
  YanProcess process = YanProcess();
  Future<void> initProcess() async {
    // TODO这儿可能有问题，adb 工具集成的时候，不需要执行su
    await process.exec('su');
  }

  Future<String> exec(String script) {
    return process.exec(script);
  }
}

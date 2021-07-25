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
    await process.exec('su');
  }
}

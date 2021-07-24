import 'package:flutter/material.dart';
import 'package:flutter_toolkit/modules/app_manager/model/app.dart';

class AppManagerProvider extends ChangeNotifier {
  //用户应用
  List<AppEntity> _userApps = <AppEntity>[];
  //系统应用
  List<AppEntity> _sysApps = <AppEntity>[];
  List<AppEntity> get userApps => _userApps;
  List<AppEntity> get sysApps => _sysApps;
  void setUserApps(List<AppEntity> map) {
    _userApps = map;
    notifyListeners();
  }

  void setSysApps(List<AppEntity> map) {
    _sysApps = map;
    notifyListeners();
  }
}

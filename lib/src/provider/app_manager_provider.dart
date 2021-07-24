import 'package:app_manager/src/model/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppManagerProvider extends GetxController {
  //用户应用
  List<AppEntity> _userApps = <AppEntity>[];
  //系统应用
  List<AppEntity> _sysApps = <AppEntity>[];
  List<AppEntity> get userApps => _userApps;
  List<AppEntity> get sysApps => _sysApps;
  void setUserApps(List<AppEntity> map) {
    _userApps = map;
    update();
  }

  void setSysApps(List<AppEntity> map) {
    _sysApps = map;
    update();
  }
}

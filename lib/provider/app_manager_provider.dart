import 'package:app_manager/global/icon_store.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class AppManagerController extends GetxController {
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

  Future<void> cacheUserIcons() async {
    for (AppEntity entity in _userApps) {
      // Log.i('缓存 ${entity.packageName} 图标');
      if (IconStore().loadCache(entity.packageName).isEmpty) {
        IconStore().cache(
          entity.packageName,
          await AppUtils.loadAppIcon(entity.packageName),
        );
      }
    }
  }

  Future<void> cacheSysIcons() async {
    for (AppEntity entity in _sysApps) {
      // Log.i('缓存 ${entity.packageName} 图标');
      IconStore().cache(
        entity.packageName,
        await AppUtils.loadAppIcon(entity.packageName),
      );
    }
  }

  void setSysApps(List<AppEntity> map) {
    _sysApps = map;
    update();
  }
}

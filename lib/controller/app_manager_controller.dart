import 'package:app_channel/app_channel.dart';
import 'package:get/get.dart';

class AppManagerController extends GetxController {
  AppManagerController() {
    // channel = Global().appChannel;
  }

  bool isInit = false;
  Future<void> init() async {
    if (isInit) {
      return;
    }
    isInit = true;
    await getUserApp();
    await getSysApp();
    // cacheUserIcon();
  }

  AppInfos get userApps => appChannel.userApps;
  AppInfos get sysApps => appChannel.systemApps;

  late AppChannel appChannel = AppChannel();

  void setAppChannel(AppChannel channel) {
    appChannel = channel;
    update();
  }

  Future<void> getUserApp() async {
    await appChannel.loadUserApps();
    update();
  }

  Future<void> getSysApp() async {
    await appChannel.loadSystemApps();
    update();
  }

  void removeEntity(AppInfo entity) {
    if (userApps.infos.contains(entity)) {
      userApps.infos.remove(entity);
    }
    if (sysApps.infos.contains(entity)) {
      sysApps.infos.remove(entity);
    }
    update();
  }
}

import 'package:app_manager/model/app.dart';
import 'package:get/get.dart';

class CheckController extends GetxController {
  List<AppInfo> check = [];

  void addCheck(AppInfo entity) {
    check.add(entity);
    update();
  }

  void removeCheck(AppInfo entity) {
    check.remove(entity);
    update();
  }

  void clearCheck() {
    check.clear();
    update();
  }
}

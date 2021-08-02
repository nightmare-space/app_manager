import 'package:app_manager/model/app.dart';
import 'package:get/get.dart';

class CheckController extends GetxController {
  List<AppEntity> check = [];

  void addCheck(AppEntity entity) {
    check.add(entity);
    update();
  }

  void removeCheck(AppEntity entity) {
    check.remove(entity);
    update();
  }

  void clearCheck() {
    check.clear();
    update();
  }
}

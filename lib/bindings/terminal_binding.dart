import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:app_manager/controller/mark_controller.dart';
import 'package:get/get.dart';

class TerminalBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppManagerController());
    Get.put(CheckController());
    Get.put(MarkController());
  }
}

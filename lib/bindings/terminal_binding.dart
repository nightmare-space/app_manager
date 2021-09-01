import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:app_manager/controller/backup_controller.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:app_manager/controller/mark_controller.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class TerminalBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppManagerController());
    Get.put(CheckController());
    Log.w('MarkController inject');
    Get.put(MarkController());
    Get.put(BackupController());
  }
}

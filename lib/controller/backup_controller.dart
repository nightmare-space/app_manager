import 'dart:io';

import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/backup.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';

class BackupController extends GetxController {
  BackupController() {
    // Log.w('BackupController');
    initBox();
  }
  String backupPath = '/sdcard/YanTool/AppManager';
  Box? box;
  Future<void> initBox() async {
    // getLocalData();
  }

  List<Backup> backups = [];
  // Future<void> addMarket(Mark mark) async {
  //   marks.mark.add(mark);
  //   update();
  //   saveToLocal();
  // }

  void saveToLocal() {}

  Future<void> getLocalData() async {
    Directory(backupPath).createSync(recursive: true);
    String lsResult = await Global().exec(' su -c "ls $backupPath | grep .gz"');
    // Log.e('lsResult -> $lsResult');
    for (final String line in lsResult.split('\n')) {
      backups.add(Backup(
        '${basenameWithoutExtension(line)}.apk',
        false,
      ));
    }
    update();
  }
}

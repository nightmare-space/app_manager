import 'dart:convert';

import 'package:app_manager/model/mark.dart';
import 'package:app_manager/model/marks.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:global_repository/global_repository.dart';
import 'package:hive/hive.dart';

String storeKey = 'mark';

class MarkController extends GetxController {
  MarkController() {
    Log.w('MarkController');
    initBox();
  }
  Box box;
  Future<void> initBox() async {
    box = await Hive.openBox('myBox', path: RuntimeEnvir.filesPath);
    getLocalData();
  }

  Marks marks = Marks(mark: []);
  Future<void> addMarket(Mark mark) async {
    marks.mark.add(mark);
    update();
    saveToLocal();
  }

  void saveToLocal() {
    box.put(storeKey, jsonEncode(marks));
  }

  void getLocalData() {
    Log.w('getLocalData');
    if (box.containsKey(storeKey)) {
      String local = box.get(storeKey);
      Log.w(local);
      marks = Marks.fromJson(jsonDecode(local));
      Log.w(marks);
      update();
    }
  }
}

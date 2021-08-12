import 'package:app_manager/model/mark.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class MarkController extends GetxController {
  MarkController() {
    getCacheMarket();
  }
  List<Mark> marks = [];
  Future<void> getCacheMarket() async {}
  Future<void> addMarket(Mark mark) async {
    marks.add(mark);
    update();
  }
}

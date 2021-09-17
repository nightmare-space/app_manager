import 'package:app_manager/model/app.dart';
import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LongPress extends StatefulWidget {
  const LongPress({Key key}) : super(key: key);

  @override
  _LongPressState createState() => _LongPressState();
}

class _LongPressState extends State<LongPress> {
  CheckController controller = Get.find();
  Widget item(String title, void Function() onTap) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 52.0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.fontColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Text(
                '选择了${controller.check.length}个应用',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            item('清除数据', () {}),
            item('卸载', () {}),
            item('冻结', () async {
              Get.back();
              AppManagerController managerController = Get.find();
              for (AppInfo entity in controller.check) {
                bool success = await AppUtils.freezeApp(entity.packageName);
                if (success) {
                  entity.freeze = true;
                  managerController.update();
                  // managerController.removeEntityByPackage(entity);
                }
              }
              controller.clearCheck();
            }),
            item('解冻', () async {
              Get.back();
              AppManagerController managerController = Get.find();
              for (AppInfo entity in controller.check) {
                bool success = await AppUtils.unFreezeApp(entity.packageName);
                if (success) {
                  entity.freeze = false;
                  managerController.update();
                  // managerController.removeEntityByPackage(entity);
                }
              }
              controller.clearCheck();
            }),
            item('打开', () {}),
            item('导出', () {}),
          ],
        ),
      ),
    );
  }
}

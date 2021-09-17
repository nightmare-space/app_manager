import 'package:app_manager/model/app.dart';
import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'backup_page.dart';

class BackupSheet extends StatefulWidget {
  const BackupSheet({Key key, this.entitys = const []}) : super(key: key);
  final List<AppInfo> entitys;

  @override
  _BackupSheetState createState() => _BackupSheetState();
}

class _BackupSheetState extends State<BackupSheet> {
  bool selectApp = false;
  bool selectData = false;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Container(
                width: 80,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '要备份哪些内容',
                style: TextStyle(
                  color: AppColors.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                BackupTag(
                  title: '应用',
                  value: selectApp,
                  accentColor: Colors.blue,
                  onChanged: (value) {
                    selectApp = value;
                    setState(() {});
                  },
                ),
                BackupTag(
                  title: '数据',
                  value: selectData,
                  accentColor: Colors.pink,
                  onChanged: (value) {
                    selectData = value;
                    setState(() {});
                  },
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            NiCardButton(
              borderRadius: 12,
              color: AppColors.accentColor,
              onTap: () {
                Get.back();
                Get.to(
                  BackupPage(
                    entitys: widget.entitys,
                  ),
                  preventDuplicates: false,
                );
              },
              child: SizedBox(
                height: 48,
                child: Center(
                    child: Text(
                  '备份',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )),
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class BackupTag extends StatelessWidget {
  const BackupTag({
    Key key,
    this.value,
    this.onChanged,
    this.title = '',
    this.accentColor,
  }) : super(key: key);
  final bool value;
  final String title;
  final Color accentColor;
  final void Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        decoration: BoxDecoration(
          color: value ? accentColor : accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: value ? Colors.white : accentColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

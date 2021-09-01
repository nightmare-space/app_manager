import 'package:app_manager/controller/backup_controller.dart';
import 'package:app_manager/controller/mark_controller.dart';
import 'package:app_manager/model/backup.dart';
import 'package:app_manager/model/mark.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class BackupListPage extends StatefulWidget {
  const BackupListPage({Key key}) : super(key: key);

  @override
  _BackupListPageState createState() => _BackupListPageState();
}

class _BackupListPageState extends State<BackupListPage> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BackupController>(
      builder: (context) {
        return ListView.builder(
          controller: _scrollController,
          itemCount: context.backups.length,
          padding: const EdgeInsets.only(bottom: 60),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext c, int i) {
            Backup backup= context.backups.elementAt(i);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffeeeeee),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            backup.appName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.fontColor,
                              fontSize: 18.w,
                            ),
                          ),
                          SizedBox(
                            height: 2.w,
                          ),
                          
                        ],
                      ),
                    ),
                   
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

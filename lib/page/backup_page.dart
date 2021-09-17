import 'dart:async';
import 'dart:io';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:app_manager/widgets/app_icon_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart' as path;

class BackupPage extends StatefulWidget {
  const BackupPage({
    Key key,
    this.backupApk = true,
    this.backupData = false,
    this.entitys,
  }) : super(key: key);
  final bool backupApk;
  final bool backupData;
  final List<AppInfo> entitys;

  @override
  _BackupPageState createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  String dataPath = '/sdcard/YanTool/AppManager';
  int limit = 1;
  int current = 0;
  int index = 0;
  AppInfo currentApp;
  String backupPath;
  bool startBackupData = false;
  bool allBackup = false;

  @override
  void initState() {
    super.initState();
    execBackup();
  }

  Future<void> execBackup() async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (AppInfo entity in widget.entitys) {
      index++;
      currentApp = entity;
      setState(() {});
      // computeSpeed();
      backupPath = '$dataPath/${currentApp.appName}.apk';
      await Global().exec(
        'mkdir -p $dataPath && cp ${currentApp.apkPath} $backupPath',
      );
      startBackupData = true;
      setState(() {});
      await Global().exec(
        'tar -zcvf $dataPath/${currentApp.appName}.tar.gz /data/data/${currentApp.packageName}',
      );
      // 最后一个需要通知结束
    }
    allBackup = true;
    setState(() {});
  }

  Future<void> computeSpeed() async {
    // 这儿的apk可能还没有
    limit = int.tryParse(await AppUtils.getFileSize(currentApp.apkPath));
    current = 0;
    setState(() {});
    while (limit != current) {
      if (!await File(backupPath).exists()) {
        continue;
      }
      current = await File('$backupPath').length();
      Log.d('current -> $current');
      Log.d('limit -> $limit');
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 1));
    }
    Log.d('完成');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: AppColors.contentBorder,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(builder: (context) {
                        if (currentApp == null) {
                          return SpinKitWave(
                            color: AppColors.accentColor,
                            size: 24,
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${currentApp.appName}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppColors.fontColor,
                                      ),
                                    ),
                                    Text(
                                      ' (${index}/${widget.entitys.length})',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppColors.fontColor
                                            .withOpacity(0.6),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Builder(builder: (context) {
                                  if (allBackup) {
                                    return Text(
                                      '备份完成',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    );
                                  }
                                  return Text(
                                    startBackupData ? '正在备份数据' : '正在备份Apk',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  );
                                }),
                              ],
                            ),
                            SizedBox(
                              width: 72,
                              height: 72,
                              child: AppIconHeader(
                                packageName: '${currentApp.packageName}',
                              ),
                            ),
                          ],
                        );
                      }),
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25.0)),
                        child: Builder(
                          builder: (context) {
                            if (allBackup) {
                              return SizedBox();
                            }
                            double value = current / limit;
                            return LinearProgressIndicator(
                              backgroundColor:
                                  AppColors.accentColor.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation(
                                value == 1.0
                                    ? AppColors.accentColor
                                    : AppColors.accentColor,
                              ),
                              value: startBackupData ? null : value,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: NiCardButton(
                color:
                    allBackup ? AppColors.accentColor : AppColors.contentBorder,
                borderRadius: 12,
                onTap: () {
                  Get.back();
                },
                child: SizedBox(
                  height: 52,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Text(
                    allBackup ? '完成' : '取消',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: allBackup ? Colors.white : AppColors.accentColor,
                    ),
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:app_manager/utils/route_extension.dart';
import 'package:app_manager/widgets/app_icon_header.dart';
import 'package:app_manager/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart';
import 'package:shortcut/shortcut.dart';

class AppSettingPage extends StatefulWidget {
  const AppSettingPage({
    Key key,
    @required this.entity,
  }) : super(key: key);
  final AppEntity entity;

  @override
  _AppSettingPageState createState() => _AppSettingPageState();
}

class _AppSettingPageState extends State<AppSettingPage> {
  List<String> activitys = [];
  String nativeDirPath = '';
  List<File> soLibs = [];
  @override
  void initState() {
    super.initState();
    getDetailsInfo();
  }

  Future<void> getDetailsInfo() async {
    activitys = await AppUtils.getAppActivitys(widget.entity.packageName);
    nativeDirPath = await AppUtils.getAppNativeDir(widget.entity.packageName);
    Directory dir = Directory(nativeDirPath);
    await for (FileSystemEntity entity in dir.list()) {
      if (entity is File) {
        soLibs.add(entity);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppEntity entity = widget.entity;
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 6.0,
        sigmaY: 6.0,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xfff0f0f0).withOpacity(0.1),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NiIconButton(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.arrow_back_ios_new),
                      ),
                      Container(
                        height: 48,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            push(AppInfoDetailPage(
                              activitys: activitys,
                              entity: entity,
                              soLibs: soLibs,
                            ));
                          },
                          onTapDown: (_) {
                            Feedback.forLongPress(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Center(
                              child: Text(
                                '更多',
                                style: TextStyle(
                                  color: AppColors.fontColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    NiCardButton(
                      borderRadius: 10,
                      child: SizedBox(
                        width: 94,
                        height: 94,
                        child: AppIconHeader(
                          packageName: widget.entity.packageName,
                        ),
                      ),
                    ),
                    Expanded(
                      child: NiCardButton(
                        borderRadius: 10,
                        onTap: () {},
                        // margin: EdgeInsets.zero,
                        child: SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '应用名 : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.fontColor,
                                      ),
                                    ),
                                    Text(entity.appName),
                                    SizedBox(width: 16),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'UID : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.fontColor,
                                      ),
                                    ),
                                    Text(entity.uid),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Version Name : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.fontColor,
                                      ),
                                    ),
                                    Text(entity.versionName),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Version Code : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.fontColor,
                                      ),
                                    ),
                                    Text(entity.versionCode),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: NiCardButton(
                        borderRadius: 10,
                        onTap: () {},
                        // margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            color: Colors.transparent,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await Clipboard.setData(ClipboardData(
                                      text: widget.entity.packageName,
                                    ));
                                    showToast('包名已复制');
                                  },
                                  child: Text(
                                    '包名',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.fontColor,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  '${widget.entity.packageName}',
                                  style: TextStyle(
                                    color: AppColors.fontColor.withOpacity(0.6),
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Clipboard.setData(ClipboardData(
                                      text: widget.entity.minSdk,
                                    ));
                                    showToast('minSdk已复制');
                                  },
                                  child: Text(
                                    'minSdk',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.fontColor,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  '${widget.entity.minSdk}',
                                  style: TextStyle(
                                    color: AppColors.fontColor.withOpacity(0.6),
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Clipboard.setData(ClipboardData(
                                      text: widget.entity.targetSdk,
                                    ));
                                    showToast('targetSdk已复制');
                                  },
                                  child: Text(
                                    'targetSdk',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.fontColor,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  '${widget.entity.targetSdk}',
                                  style: TextStyle(
                                    color: AppColors.fontColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: NiCardButton(
                        borderRadius: 10,
                        onTap: () {},
                        // margin: EdgeInsets.zero,
                        child: SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await Clipboard.setData(ClipboardData(
                                      text: widget.entity.apkPath,
                                    ));
                                    showToast('Apk路径已复制');
                                  },
                                  child: Text(
                                    'Apk路径',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.fontColor,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  '${widget.entity.apkPath}',
                                  style: TextStyle(
                                    color: AppColors.fontColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                NiCardButton(
                  borderRadius: 16,
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          buildItem('打开', onTap: () async {
                            // if (GetPlatform.isDesktop) {
                            //   await Global().exec(
                            //       'am start -n ${widget.apps[0].packageName}/$activityName');
                            // }

                            AppUtils.launchActivity(
                              entity.packageName,
                              await AppUtils.getAppMainActivity(
                                  entity.packageName),
                            );
                            // Log.w('activityName -> $activityName');
                            // final AndroidIntent intent = AndroidIntent(
                            //   action: 'android.intent.action.MAIN',
                            //   package: entity.packageName,
                            //   componentName: activityName,
                            //   category: 'android.intent.category.LAUNCHER',
                            // );
                            // intent.launch();
                          }),
                          buildItem('应用详情', onTap: () async {
                            final AndroidIntent intent = AndroidIntent(
                              // NEW TASK
                              flags: [0x10000000],
                              action: 'action_application_details_settings',
                              data: 'package:${entity.packageName}',
                            );
                            intent.launch();
                          }),
                          buildItem('清除App数据', danger: true, onTap: () {
                            AppUtils.clearAppData(entity.packageName);
                          }),
                          buildItem('卸载', danger: true, onTap: () async {
                            await AppUtils.unInstallApp(entity.packageName);

                            AppManagerController controller = Get.find();
                            controller.removeEntity(entity);
                            controller.update();
                          }),
                          Builder(builder: (_) {
                            if (entity.freeze) {
                              return buildItem('解冻', danger: false,
                                  onTap: () async {
                                await AppUtils.unFreezeApp(entity.packageName);
                                entity.freeze = false;
                                setState(() {});
                                AppManagerController controller = Get.find();
                                controller.update();
                              });
                            }
                            return buildItem('冻结', danger: true,
                                onTap: () async {
                              bool success =
                                  await AppUtils.freezeApp(entity.packageName);
                              if (success) {
                                entity.freeze = true;
                                setState(() {});
                                AppManagerController controller = Get.find();
                                controller.update();
                              } else {
                                showToast(
                                    '禁用失败,当前root状态${await Global().process.isRoot()}');
                              }
                            });
                          }),
                          Builder(builder: (_) {
                            if (entity.hide) {
                              return buildItem('显示', danger: false,
                                  onTap: () async {
                                bool success =
                                    await AppUtils.showApp(entity.packageName);
                                if (success) {
                                  entity.hide = false;
                                  setState(() {});
                                  AppManagerController controller = Get.find();
                                  controller.update();
                                } else {
                                  showToast(
                                      '显示失败,当前root状态${await Global().process.isRoot()}');
                                }
                              });
                            }
                            return buildItem('隐藏', danger: true,
                                onTap: () async {
                              bool success =
                                  await AppUtils.hideApp(entity.packageName);
                              if (success) {
                                entity.hide = true;
                                setState(() {});
                                AppManagerController controller = Get.find();
                                controller.update();
                              } else {
                                showToast(
                                    '隐藏失败,当前root状态${await Global().process.isRoot()}');
                              }
                            });
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InkWell buildItem(
    String title, {
    void Function() onTap,
    bool danger = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 54,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: danger ? Colors.red : AppColors.fontColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppInfoDetailPage extends StatefulWidget {
  const AppInfoDetailPage({
    key,
    this.activitys,
    this.entity,
    this.soLibs,
  }) : super(key: key);
  final List<String> activitys;
  final AppEntity entity;
  final List<File> soLibs;

  @override
  _AppInfoDetailPageState createState() => _AppInfoDetailPageState();
}

class _AppInfoDetailPageState extends State<AppInfoDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              NiCardButton(
                borderRadius: 20,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          '活动列表',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Builder(builder: (_) {
                        List<Widget> children = [];
                        for (String activity in widget.activitys) {
                          children.add(Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                AppUtils.launchActivity(
                                  widget.entity.packageName,
                                  activity,
                                );
                                Shortcut.addShortcut(
                                  assetName: 'assets/placeholder.png',
                                  name: activity.split('.').last,
                                  packageName: widget.entity.packageName,
                                  activityName: activity,
                                  intentExtra: {},
                                );
                              },
                              child: SizedBox(
                                height: 48,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      activity,
                                      style: TextStyle(
                                        color: AppColors.fontColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ));
                        }
                        return Column(
                          children: children,
                        );
                      }),
                    ],
                  ),
                ),
              ),
              NiCardButton(
                borderRadius: 20,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          'So库',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Builder(builder: (_) {
                        List<Widget> children = [];
                        for (File entity in widget.soLibs) {
                          children.add(Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {},
                              child: SizedBox(
                                height: 48,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Text(
                                          basename(entity.path),
                                          style: TextStyle(
                                            color: AppColors.fontColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '(${FileSizeUtils.getFileSize(entity.lengthSync())})',
                                          style: TextStyle(
                                            color: AppColors.fontColor
                                                .withOpacity(0.6),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ));
                        }

                        return Column(
                          children: children,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

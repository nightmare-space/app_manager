import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:app_manager/controller/mark_controller.dart';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:app_manager/model/app_details.dart';
import 'package:app_manager/model/mark.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:app_manager/utils/plugin_utils.dart';
import 'package:app_manager/utils/route_extension.dart';
import 'package:app_manager/widgets/app_icon_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart' as path;
import 'package:shortcut/shortcut.dart';

import 'backup_sheet.dart';

class AppSettingPage extends StatefulWidget {
  const AppSettingPage({
    Key key,
    @required this.entity,
  }) : super(key: key);
  final AppInfo entity;

  @override
  _AppSettingPageState createState() => _AppSettingPageState();
}

class _AppSettingPageState extends State<AppSettingPage> {
  AppManagerController controller = Get.find();
  @override
  void initState() {
    super.initState();
    getDetailsInfo();
  }

  String getTimeStringFromTimestamp(String timestamp) {
    return '${DateTime.fromMillisecondsSinceEpoch(int.tryParse(timestamp))}';
    // https://www.coloros.com/rom/firmware?id=126
  }

  Future<String> getFileSize(String path) async {
    return '123';
    return await Global().exec('stat -c "%s" $path');
  }

  Future<void> getDetailsInfo() async {
    AppDetails details = AppDetails();
    details.activitys = await AppUtils.getAppActivitys(
      widget.entity.packageName,
    );
    String result = await AppUtils.getAppDetails(widget.entity.packageName);
    List<String> results = result.split('\r');
    Log.w('result -> $results');
    details.installTime = getTimeStringFromTimestamp(results[0]);
    details.updateTime = getTimeStringFromTimestamp(results[1]);
    details.dataDir = results[2];
    details.libDir = results[3];
    String ls = await Global().exec('ls ${details.libDir}');
    if (ls.isNotEmpty) {
      for (String path in ls.split('\n')) {
        details.soLibs.add(
          SoEntity(path, await getFileSize(details.libDir + '/' + path)),
        );
      }
    }

    details.apkSize = await getFileSize(widget.entity.apkPath);
    Log.w('apkSize -> ${details.apkSize}}');
    String md5 = await Global().exec('md5sum ${widget.entity.apkPath}');
    md5 = md5.replaceAll(RegExp(' .*'), '');
    String sha1 = await Global().exec('sha1sum ${widget.entity.apkPath}');
    sha1 = sha1.replaceAll(RegExp(' .*'), '');
    String sha256 = await Global().exec('sha256sum ${widget.entity.apkPath}');
    sha256 = sha256.replaceAll(RegExp(' .*'), '');
    details.apkMd5 = md5;
    details.apkSha1 = sha1;
    details.apkSha256 = sha256;
    widget.entity.details = details;
    List<String> pers = await AppUtils.getAppPermission(
      widget.entity.packageName,
    );
    Log.w('pers -> $pers');
    for (String line in pers) {
      String name = line.split(' ').first;
      String des = line.split(' ')[1];
      String grant = line.split(' ')[2];
      details.permission.add(PermissionEntity(name, des, grant == 'true'));
    }
    controller.update();
  }

  @override
  Widget build(BuildContext context) {
    AppInfo entity = widget.entity;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.of(context).pop();
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 6.0,
          sigmaY: 6.0,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                borderRadius: BorderRadius.circular(16.w),
                color: Colors.white,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Center(
                        child: Container(
                          width: 80,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.contentBorder,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      buildItem('打开', onTap: () async {
                        // if (GetPlatform.isDesktop) {
                        //   await Global().exec(
                        //       'am start -n ${widget.apps[0].packageName}/$activityName');
                        // }

                        AppUtils.launchActivity(
                          entity.packageName,
                          await AppUtils.getAppMainActivity(entity.packageName),
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
                        Get.back();
                        final AndroidIntent intent = AndroidIntent(
                          // NEW TASK
                          flags: [0x10000000],
                          action: 'action_application_details_settings',
                          data: 'package:${entity.packageName}',
                        );
                        intent.launch();
                      }),
                      buildItem('备份', danger: false, onTap: () {
                        Get.back();
                        CheckController checkController = Get.find();
                        if (checkController.check.isEmpty) {
                          Get.bottomSheet(BackupSheet(
                            entitys: [entity],
                          ));
                        } else {
                          Get.bottomSheet(BackupSheet(
                            entitys: checkController.check,
                          ));
                        }
                        // AppUtils.clearAppData(entity.packageName);
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
                        return buildItem('冻结', danger: true, onTap: () async {
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
                        return buildItem('隐藏', danger: true, onTap: () async {
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
                      buildItem('查看详细信息', danger: false, onTap: () {
                        Get.back();
                        push(AppInfoDetailPage(
                          entity: widget.entity,
                        ));
                        // AppUtils.clearAppData(entity.packageName);
                      }),
                      buildItem('分享', danger: false, onTap: () {
                        Get.back();
                        PluginUtils.shareFile(widget.entity.apkPath);
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
    this.entity,
  }) : super(key: key);
  final AppInfo entity;

  @override
  _AppInfoDetailPageState createState() => _AppInfoDetailPageState();
}

class _AppInfoDetailPageState extends State<AppInfoDetailPage> {
  int page = 0;
  PageController controller = PageController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppManagerController>(builder: (_) {
      if (widget.entity.details == null) {
        return const SpinKitThreeBounce(
          color: Colors.indigo,
          size: 24,
        );
      }
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                NiIconButton(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.arrow_back_ios_new),
                ),
                buildBody(),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: DetailsTab(
                    value: page,
                    controller: controller,
                    onChange: (value) {
                      page = value;
                      setState(() {});
                      controller.animateToPage(
                        page,
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        curve: Curves.ease,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Expanded buildBody() {
    return Expanded(
      child: PageView(
        controller: controller,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Builder(builder: (context) {
              AppInfo entity = widget.entity;
              return SingleChildScrollView(
                padding: EdgeInsets.zero,
                physics: BouncingScrollPhysics(),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      children: [
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.contentBorder,
                                borderRadius: BorderRadius.circular(
                                  16,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 250,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 60,
                                                height: 60,
                                                child: AppIconHeader(
                                                  padding: EdgeInsets.zero,
                                                  packageName:
                                                      widget.entity.packageName,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        entity.appName,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .fontColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        'Version Name : ',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .fontColor,
                                                        ),
                                                      ),
                                                      Text(entity.versionName),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        'Version Code : ',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .fontColor,
                                                        ),
                                                      ),
                                                      Text(entity.versionCode),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 16.w,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.contentBorder,
                                  borderRadius: BorderRadius.circular(
                                    16,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'UID : ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.fontColor,
                                            ),
                                          ),
                                          Text(entity.uid),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      InkWell(
                                        onTap: () async {
                                          await Clipboard.setData(ClipboardData(
                                            text: widget.entity.minSdk,
                                          ));
                                          showToast('minSdk已复制');
                                        },
                                        child: Row(
                                          children: [
                                            const Text(
                                              'minSdk : ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.fontColor,
                                              ),
                                            ),
                                            Text(
                                              widget.entity.minSdk,
                                              style: TextStyle(
                                                color: AppColors.fontColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          await Clipboard.setData(ClipboardData(
                                            text: widget.entity.targetSdk,
                                          ));
                                          showToast('targetSdk已复制');
                                        },
                                        child: Row(
                                          children: [
                                            const Text(
                                              'targetSdk : ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.fontColor,
                                              ),
                                            ),
                                            Text(
                                              widget.entity.targetSdk,
                                              style: TextStyle(
                                                color: AppColors.fontColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16.w,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.contentBorder,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              buildItem('应用包名', entity.packageName),
                              buildItem(
                                '应用安装时间',
                                entity.details.installTime,
                              ),
                              buildItem(
                                '应用更新时间',
                                entity.details.updateTime,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 16.w,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.contentBorder,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              buildItem(
                                'Apk大小',
                                FileSizeUtils.getFileSizeFromStr(
                                  entity.details.apkSize,
                                ),
                              ),
                              buildItem('Apk MD5', entity.details.apkMd5),
                              buildItem('Apk SHA1', entity.details.apkSha1),
                              buildItem('Apk SHA256', entity.details.apkSha256),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 16.w,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.contentBorder,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              buildItem('Apk路径', entity.apkPath),
                              buildItem('so库路径', entity.details.libDir),
                              buildItem('私有路径', entity.details.dataDir),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          Builder(builder: (_) {
            List<Widget> children = [];
            for (String activity in widget.entity.details.activitys) {
              children.add(Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    MarkController controller = Get.find();
                    controller.addMarket(Mark(
                      name: '小爱快捷',
                      package: widget.entity.packageName,
                      component: activity,
                    ));
                    showToast('已添加到收藏');
                    // AppUtils.launchActivity(
                    //   widget.entity.packageName,
                    //   activity,
                    // );
                    // Shortcut.addShortcut(
                    //   assetName: 'assets/placeholder.png',
                    //   name: activity.split('.').last,
                    //   packageName: widget.entity.packageName,
                    //   activityName: activity,
                    //   intentExtra: {},
                    // );
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
                          style: const TextStyle(
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
            return SingleChildScrollView(
              child: Column(
                children: children,
              ),
            );
          }),
          Builder(builder: (_) {
            List<Widget> children = [];
            for (SoEntity entity in widget.entity.details.soLibs) {
              children.add(Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {},
                  child: SizedBox(
                    height: 48,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(
                              path.basename(entity.path),
                              style: const TextStyle(
                                color: AppColors.fontColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '(${FileSizeUtils.getFileSizeFromStr(entity.size)})',
                              style: TextStyle(
                                color: AppColors.fontColor.withOpacity(0.6),
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

            return SingleChildScrollView(
              child: Column(
                children: children,
              ),
            );
          }),
          Builder(builder: (_) {
            List<Widget> children = [];
            for (PermissionEntity entity in widget.entity.details.permission) {
              children.add(Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {},
                  child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entity.name,
                              style: const TextStyle(
                                color: AppColors.fontColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              entity.description,
                              style: TextStyle(
                                color: AppColors.fontColor.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
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
            return SingleChildScrollView(
              child: Column(
                children: children,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildItem(String title, String value) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: value));
          showToast('已复制');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.fontColor,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.fontColor.withOpacity(0.8),
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

final List<String> tabs = [
  '基础',
  '活动列表',
  'So库',
  '权限',
];
final List<Color> colors = [
  Colors.indigo,
  Colors.deepPurple,
  Colors.teal,
  Colors.amber,
];

class DetailsTab extends StatefulWidget {
  const DetailsTab({
    Key key,
    this.value,
    this.onChange,
    this.controller,
  }) : super(key: key);
  final int value;
  final void Function(int value) onChange;
  final PageController controller;

  @override
  _DetailsTabState createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
  int _value;
  @override
  void initState() {
    super.initState();
    _value = widget.value;
    widget.controller.addListener(() {
      if (widget.controller.page.round() != _value) {
        _value = widget.controller.page.round();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int i = 0; i < tabs.length; i++) {
      bool isCheck = _value == i;
      children.add(
        GestureDetector(
          onTap: () {
            widget.onChange(i);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isCheck ? colors[i] : colors[i].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Text(
              tabs[i],
              style: TextStyle(
                color: isCheck ? Colors.white : colors[i],
                fontSize: 16.w,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: children,
      ),
    );
  }
}

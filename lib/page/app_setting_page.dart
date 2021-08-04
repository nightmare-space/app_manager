import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:app_manager/model/app_details.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:app_manager/utils/route_extension.dart';
import 'package:app_manager/widgets/app_icon_header.dart';
import 'package:app_manager/widgets/custom_icon_button.dart';
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
  final AppEntity entity;

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
    for (String path in ls.split('\n')) {
      details.soLibs.add(
        SoEntity(path, await getFileSize(details.libDir + '/' + path)),
      );
    }
    details.apkSize = '';
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
    AppEntity entity = widget.entity;
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 6.0,
        sigmaY: 6.0,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xfff0f0f0).withOpacity(0.1),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NiIconButton(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(Icons.arrow_back_ios_new),
                      ),
                      SizedBox(
                        height: 48,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            push(AppInfoDetailPage(
                              entity: widget.entity,
                            ));
                          },
                          onTapDown: (_) {
                            Feedback.forLongPress(context);
                          },
                          child: const Padding(
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
                                    const Text(
                                      '应用名 : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.fontColor,
                                      ),
                                    ),
                                    Text(entity.appName),
                                    const SizedBox(width: 16),
                                  ],
                                ),
                                const SizedBox(height: 4),
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
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text(
                                      'Version Name : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.fontColor,
                                      ),
                                    ),
                                    Text(entity.versionName),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text(
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
                                  child: const Text(
                                    '包名',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.fontColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  widget.entity.packageName,
                                  style: TextStyle(
                                    color: AppColors.fontColor.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Clipboard.setData(ClipboardData(
                                      text: widget.entity.minSdk,
                                    ));
                                    showToast('minSdk已复制');
                                  },
                                  child: const Text(
                                    'minSdk',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.fontColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  widget.entity.minSdk,
                                  style: TextStyle(
                                    color: AppColors.fontColor.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Clipboard.setData(ClipboardData(
                                      text: widget.entity.targetSdk,
                                    ));
                                    showToast('targetSdk已复制');
                                  },
                                  child: const Text(
                                    'targetSdk',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.fontColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  widget.entity.targetSdk,
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
                                  child: const Text(
                                    'Apk路径',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.fontColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  widget.entity.apkPath,
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
                          buildItem('备份', danger: false, onTap: () {
                            Get.bottomSheet(const BackupSheet());
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
    this.entity,
  }) : super(key: key);
  final AppEntity entity;

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
                DetailsTab(
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
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: PageView(
                    controller: controller,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Builder(builder: (context) {
                          AppEntity entity = widget.entity;
                          return SingleChildScrollView(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  buildItem('应用名称', entity.appName),
                                  buildItem('版本号', entity.versionCode),
                                  buildItem('版本名称', entity.versionName),
                                  buildItem('应用包名', entity.packageName),
                                  buildItem('minSdk', entity.minSdk),
                                  buildItem('targetSdk', entity.targetSdk),
                                  buildItem('uid', entity.uid),
                                  buildItem(
                                    '应用安装时间',
                                    entity.details.installTime,
                                  ),
                                  buildItem(
                                    '应用更新时间',
                                    entity.details.updateTime,
                                  ),
                                  buildItem('Apk大小', entity.details.apkSize),
                                  buildItem('Apk MD5', entity.details.apkMd5),
                                  buildItem('Apk SHA1', entity.details.apkSha1),
                                  buildItem(
                                      'Apk SHA256', entity.details.apkSha256),
                                  buildItem('Apk路径', entity.apkPath),
                                  buildItem('so库路径', entity.details.libDir),
                                  buildItem('私有路径', entity.details.dataDir),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      Builder(builder: (_) {
                        List<Widget> children = [];
                        for (String activity
                            in widget.entity.details.activitys) {
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
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
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

                        return SingleChildScrollView(
                          child: Column(
                            children: children,
                          ),
                        );
                      }),
                      Builder(builder: (_) {
                        List<Widget> children = [];
                        for (PermissionEntity entity
                            in widget.entity.details.permission) {
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color: AppColors.fontColor
                                                .withOpacity(0.8),
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
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
                color: AppColors.fontColor.withOpacity(0.8),
              ),
            ),
          ),
        ],
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
                fontSize: 18,
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

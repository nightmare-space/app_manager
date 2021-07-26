import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:app_manager/global/global.dart';
import 'package:app_manager/model/app.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:app_manager/widgets/app_icon_header.dart';
import 'package:app_manager/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class AppSettingPage extends StatefulWidget {
  const AppSettingPage({Key key, @required this.entity}) : super(key: key);
  final AppEntity entity;

  @override
  _AppSettingPageState createState() => _AppSettingPageState();
}

class _AppSettingPageState extends State<AppSettingPage> {
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
        backgroundColor: AppColors.accentColor.withOpacity(0.1),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: NiIconButton(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back_ios_new),
                  ),
                ),
                Row(
                  children: [
                    NiCardButton(
                      borderRadius: 10,
                      child: SizedBox(
                        width: 76,
                        height: 76,
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

                            const MethodChannel jump = MethodChannel('jump');
                            jump.invokeMethod(
                              [
                                entity.packageName,
                                AppUtils.getAppMainActivity(entity.packageName),
                              ].join('\n'),
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
                          buildItem('清除App数据', danger: true),
                          buildItem('卸载', danger: true),
                          buildItem('冻结', danger: true, onTap: () {
                            AppUtils.freezeApp(entity.packageName);
                          }),
                          buildItem('隐藏', danger: true, onTap: () {
                            AppUtils.hideApp(entity.packageName);
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

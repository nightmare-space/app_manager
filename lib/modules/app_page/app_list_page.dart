import 'package:app_channel/app_channel.dart';
import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/widgets/app_icon.dart';
import 'package:app_manager/widgets/highlight_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class AppListPage extends StatefulWidget {
  const AppListPage({
    Key? key,
    this.appInfos = const AppInfos(infos: []),
    this.filter = '',
  }) : super(key: key);
  final AppInfos appInfos;
  final String filter;
  @override
  AppListPageState createState() => AppListPageState();
}

class AppListPageState extends State<AppListPage> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppInfos apps = AppInfos(infos: List.from(widget.appInfos.infos));
    if (apps.infos.isEmpty) {
      return const SpinKitThreeBounce(color: AppColors.accentColor, size: 16.0);
    } else {
      if (widget.filter.isNotEmpty) {
        // 移除不包含关键字的item
        apps.infos.removeWhere((element) {
          return !element.appName.toLowerCase().contains(widget.filter) && !element.package.toLowerCase().contains(widget.filter);
        });
      }
      return ListView.builder(
        controller: _scrollController,
        itemCount: apps.infos.length,
        padding: const EdgeInsets.only(bottom: 60),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext c, int i) {
          return AppItem(
            entity: apps.infos[i],
            filter: widget.filter,
          );
        },
      );
    }
  }
}

class AppItem extends StatefulWidget {
  const AppItem({
    Key? key,
    this.entity,
    this.filter,
  }) : super(key: key);
  final AppInfo? entity;
  final String? filter;

  @override
  _AppItemState createState() => _AppItemState();
}

class _AppItemState extends State<AppItem> {
  CheckController checkController = Get.find();
  AppManagerController am = Get.find();

  handleOnTap() {
    AppInfo? entity = widget.entity;
    final check = checkController.check;
    if (check.contains(entity)) {
      checkController.removeCheck(entity);
    } else {
      checkController.addCheck(entity);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  Widget tagItem(String data) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        4.w,
        4.w,
        4.w,
        2.w,
      ),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.w),
      ),
      child: Text(
        data,
        style: TextStyle(
          color: Colors.red,
          fontSize: 10.w,
          height: 1.0,
        ),
      ),
    );
  }

  Offset offset = const Offset(0.0, 0.0);
  @override
  Widget build(BuildContext context) {
    AppInfo entity = widget.entity!;
    final check = checkController.check;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onLongPress: () {
            // Get.dialog(AppSettingPage(
            //   entity: entity,
            //   offset: offset,
            // ));
          },
          child: Listener(
            onPointerDown: (PointerDownEvent event) {
              if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
                // Get.dialog(AppSettingPage(
                //   entity: entity,
                //   offset: offset,
                // ));
              }
            },
            child: GestureDetector(
              onTap: handleOnTap,
              behavior: HitTestBehavior.translucent,
              onPanDown: (details) {
                offset = details.globalPosition;
              },
              child: MouseRegion(
                onHover: (event) {
                  offset = event.position;
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 68,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: AppIcon(
                                key: Key(entity.package),
                                packageName: entity.package,
                                channel: am.appChannel,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      HighlightText(
                                        data: entity.appName,
                                        hightlightData: widget.filter,
                                        defaultStyle: const TextStyle(
                                          color: AppColors.fontColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (!entity.enabled) tagItem('被冻结'),
                                      if (entity.hide) tagItem('被隐藏'),
                                    ],
                                  ),
                                  SingleChildScrollView(
                                    controller: ScrollController(),
                                    scrollDirection: Axis.horizontal,
                                    child: HighlightText(
                                      data: entity.package,
                                      hightlightData: widget.filter,
                                      defaultStyle: const TextStyle(
                                        color: AppColors.fontColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${entity.versionName}(${entity.versionCode})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.fontColor.withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: check.contains(entity),
                        onChanged: (bool? v) {
                          handleOnTap();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

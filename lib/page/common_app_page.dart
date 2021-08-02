import 'package:app_manager/model/app.dart';
import 'package:app_manager/page/app_setting_page.dart';
import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:app_manager/utils/route_extension.dart';
import 'package:app_manager/widgets/app_icon_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'already_install.dart';
import 'long_press_dialog.dart';

class CommonAppPage extends StatefulWidget {
  const CommonAppPage({
    Key key,
    this.appList = const [],
    this.filter,
  }) : super(key: key);
  final List<AppEntity> appList;
  final String filter;
  @override
  CommonAppPageState createState() => CommonAppPageState();
}

class CommonAppPageState extends State<CommonAppPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<AppEntity> apps = List.from(widget.appList);
    if (apps.isEmpty) {
      return SpinKitThreeBounce(
        color: AppColors.accentColor,
        size: 16.0,
      );
    } else {
      if (widget.filter.isNotEmpty) {
        apps.removeWhere((element) {
          return !element.appName.toLowerCase().contains(widget.filter) &&
              !element.packageName.toLowerCase().contains(widget.filter);
        });
      }
      return ListView.builder(
        itemCount: apps.length,
        padding: EdgeInsets.only(bottom: 60),
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext c, int i) {
          return AppItem(
            entity: apps[i],
            filter: widget.filter,
          );
        },
      );
    }
  }
}

class AppItem extends StatefulWidget {
  const AppItem({
    Key key,
    this.entity,
    this.filter,
  }) : super(key: key);
  final AppEntity entity;
  final String filter;

  @override
  _AppItemState createState() => _AppItemState();
}

class _AppItemState extends State<AppItem> {
  AppManagerController controller = Get.find();
  CheckController checkController = Get.find();
  handleOnTap() {
    AppEntity entity = widget.entity;
    final check = checkController.check;
    if (check.contains(entity)) {
      checkController.removeCheck(entity);
    } else {
      checkController.addCheck(entity);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AppEntity entity = widget.entity;
    final check = checkController.check;
    return InkWell(
      onTap: handleOnTap,
      onLongPress: () {
        push(AppSettingPage(
          entity: entity,
        ));
        // showCustomDialog<void>(
        //     context: context,
        //     child: LongPress(
        //       apps: <AppEntity>[apps[i]],
        //     ));
      },
      child: SizedBox(
        height: 54.0,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  AppIconHeader(
                    key: Key(entity.packageName),
                    packageName: entity.packageName,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Builder(builder: (_) {
                              if (widget.filter.isNotEmpty) {
                                int index = entity.appName
                                    .toLowerCase()
                                    .indexOf(widget.filter);
                                if (index != -1) {
                                  List<int> highlightOffset = [index];
                                  for (int i = 0;
                                      i < widget.filter.length - 1;
                                      i++) {
                                    highlightOffset.add(highlightOffset[i] + 1);
                                  }
                                  return RichText(
                                    text: TextSpan(
                                      text: '',
                                      style: TextStyle(
                                        color: AppColors.fontColor,
                                      ),
                                      children: [
                                        for (int i = 0;
                                            i < entity.appName.length;
                                            i++)
                                          TextSpan(
                                            text: entity.appName[i],
                                            style: TextStyle(
                                              color: highlightOffset.contains(i)
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : AppColors.fontColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }
                              }
                              return Text(
                                entity.appName,
                                style: TextStyle(
                                  color: AppColors.fontColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                            if (entity.freeze)
                              Text(
                                '(被冻结)',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            if (entity.hide)
                              Text(
                                '(被隐藏)',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                        SingleChildScrollView(
                          controller: ScrollController(),
                          scrollDirection: Axis.horizontal,
                          child: Builder(builder: (_) {
                            if (widget.filter.isNotEmpty) {
                              int index = entity.packageName
                                  .toLowerCase()
                                  .indexOf(widget.filter);
                              if (index != -1) {
                                List<int> highlightOffset = [index];
                                for (int i = 0;
                                    i < widget.filter.length - 1;
                                    i++) {
                                  highlightOffset.add(highlightOffset[i] + 1);
                                }
                                return RichText(
                                  text: TextSpan(
                                    text: '',
                                    style: TextStyle(
                                      color: AppColors.fontColor,
                                    ),
                                    children: [
                                      for (int i = 0;
                                          i < entity.packageName.length;
                                          i++)
                                        TextSpan(
                                          text: entity.packageName[i],
                                          style: TextStyle(
                                            color: highlightOffset.contains(i)
                                                ? Theme.of(context).primaryColor
                                                : AppColors.fontColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }
                            }
                            return Text(
                              entity.packageName,
                              style: TextStyle(
                                color: AppColors.fontColor.withOpacity(0.8),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: check.contains(entity),
              onChanged: (bool v) {
                handleOnTap();
              },
            )
          ],
        ),
      ),
    );
  }
}

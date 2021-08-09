import 'package:app_manager/model/app.dart';
import 'package:app_manager/page/app_setting_page.dart';
import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/utils/route_extension.dart';
import 'package:app_manager/widgets/app_icon_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

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
    List<AppEntity> apps = List.from(widget.appList);
    if (apps.isEmpty) {
      return const SpinKitThreeBounce(
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
        controller: _scrollController,
        itemCount: apps.length,
        padding: const EdgeInsets.only(bottom: 60),
        physics: const BouncingScrollPhysics(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: handleOnTap,
          onLongPress: () {
            Get.bottomSheet(
              AppSettingPage(
                entity: entity,
              ),
              isScrollControlled: true,
            );
            // push(AppSettingPage(
            //   entity: entity,
            // ));
            // showCustomDialog<void>(
            //     context: context,
            //     child: LongPress(
            //       apps: <AppEntity>[apps[i]],
            //     ));
          },
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
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
                          child: AppIconHeader(
                            key: Key(entity.packageName),
                            packageName: entity.packageName,
                          ),
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
                                          highlightOffset
                                              .add(highlightOffset[i] + 1);
                                        }
                                        return RichText(
                                          text: TextSpan(
                                            text: '',
                                            style: const TextStyle(
                                              color: AppColors.fontColor,
                                            ),
                                            children: [
                                              for (int i = 0;
                                                  i < entity.appName.length;
                                                  i++)
                                                TextSpan(
                                                  text: entity.appName[i],
                                                  style: TextStyle(
                                                    color: highlightOffset
                                                            .contains(i)
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
                                      style: const TextStyle(
                                        color: AppColors.fontColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }),
                                  if (entity.freeze)
                                    const Text(
                                      '(被冻结)',
                                      style: TextStyle(
                                        color: Colors.red,
                                        height: 1,
                                      ),
                                    ),
                                  if (entity.hide)
                                    const Text(
                                      '(被隐藏)',
                                      style: TextStyle(
                                        color: Colors.red,
                                        height: 1,
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
                                        highlightOffset
                                            .add(highlightOffset[i] + 1);
                                      }
                                      return RichText(
                                        text: TextSpan(
                                          text: '',
                                          style: const TextStyle(
                                            color: AppColors.fontColor,
                                          ),
                                          children: [
                                            for (int i = 0;
                                                i < entity.packageName.length;
                                                i++)
                                              TextSpan(
                                                text: entity.packageName[i],
                                                style: TextStyle(
                                                  color: highlightOffset
                                                          .contains(i)
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : AppColors.fontColor
                                                          .withOpacity(0.8),
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
                                      color:
                                          AppColors.fontColor.withOpacity(0.9),
                                    ),
                                  );
                                }),
                              ),
                              SizedBox(
                                height: 4,
                              ),
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
                    onChanged: (bool v) {
                      handleOnTap();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

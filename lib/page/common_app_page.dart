import 'package:app_manager/model/app.dart';
import 'package:app_manager/page/app_setting_page.dart';
import 'package:app_manager/provider/app_manager_controller.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/utils/route_extension.dart';
import 'package:app_manager/widgets/app_icon_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'already_install.dart';
import 'long_press_dialog.dart';

class CommonAppPage extends StatefulWidget {
  final List<AppEntity> appList;

  const CommonAppPage({Key key, this.appList = const []}) : super(key: key);
  @override
  CommonAppPageState createState() => CommonAppPageState();
}

class CommonAppPageState extends State<CommonAppPage> {
  List<String> check = <String>[];

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
    List<AppEntity> apps = widget.appList;
    if (apps.isEmpty) {
      return SpinKitThreeBounce(
        color: AppColors.accentColor,
        size: 16.0,
      );
    } else {
      return ListView.builder(
        itemCount: apps.length,
        padding: EdgeInsets.only(bottom: 60),
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext c, int i) {
          final String packageName = apps[i].packageName;
          return InkWell(
            onTap: () {
              if (check.contains(packageName)) {
                check.remove(packageName);
              } else {
                check.add(packageName);
              }
              setState(() {});
            },
            onLongPress: () {
              push(AppSettingPage(
                entity: apps[i],
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
                          key: Key(apps[i].packageName),
                          packageName: apps[i].packageName,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  Text(
                                    apps[i].appName,
                                    style: TextStyle(
                                      color: AppColors.fontColor,
                                    ),
                                  ),
                                  if (apps[i].freeze)
                                    Text(
                                      '(被冻结)',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                              SingleChildScrollView(
                                controller: ScrollController(),
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  apps[i].packageName,
                                  style: TextStyle(
                                    color: AppColors.fontColor.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: check.contains(packageName),
                    onChanged: (bool v) {
                      if (check.contains(packageName)) {
                        check.remove(packageName);
                      } else {
                        check.add(packageName);
                      }
                      setState(() {});
                    },
                  )
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

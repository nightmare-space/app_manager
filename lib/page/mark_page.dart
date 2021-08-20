import 'package:app_manager/controller/mark_controller.dart';
import 'package:app_manager/model/mark.dart';
import 'package:app_manager/theme/app_colors.dart';
import 'package:app_manager/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:global_repository/src/utils/screen_util.dart';

class MarkPage extends StatefulWidget {
  const MarkPage({Key key}) : super(key: key);

  @override
  _MarkPageState createState() => _MarkPageState();
}

class _MarkPageState extends State<MarkPage> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarkController>(
      builder: (context) {
        return ListView.builder(
          controller: _scrollController,
          itemCount: context.marks.mark.length,
          padding: const EdgeInsets.only(bottom: 60),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext c, int i) {
            Mark mark = context.marks.mark.elementAt(i);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffeeeeee),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mark.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.fontColor,
                              fontSize: 18.w,
                            ),
                          ),
                          SizedBox(
                            height: 2.w,
                          ),
                          Text(
                            mark.package + '/' + mark.component,
                            style: TextStyle(
                              // fontWeight: FontWeight.bold,
                              color: AppColors.fontColor.withOpacity(0.6),
                              fontSize: 14.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                    NiCardButton(
                      color: Color(0xffe0e0e0),
                      blurRadius: 0,
                      borderRadius: 20.w,
                      onTap: () {
                        AppUtils.launchActivity(mark.package, mark.component);
                      },
                      child: SizedBox(
                        width: 40.w,
                        height: 40.w,
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.black.withOpacity(0.4),
                        ),
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

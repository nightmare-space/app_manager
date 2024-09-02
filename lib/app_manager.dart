library app_manager;

import 'global/global.dart';

export 'home.dart';
export 'routes/app_pages.dart';
export 'bindings/app_manager_binding.dart';
export 'modules/app_page/app_list_page.dart';
export 'widgets/app_icon.dart';
export 'widgets/search_box.dart';
export 'widgets/highlight_text.dart';
export 'package:app_channel/app_channel.dart';

class AppManager {
  static Global globalInstance = Global();
}

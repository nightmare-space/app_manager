import 'package:app_manager/core/interface/app_channel.dart';
import 'package:app_manager/model/app.dart';

import 'local_app_channel.dart';

class RemoteAppChannel extends LocalAppChannel {
  RemoteAppChannel() {
    port = 6001;
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:global_repository/global_repository.dart';

const int msgByteLen = 2;
const int msgCodeByteLen = 2;
const int minMsgByteLen = msgByteLen + msgCodeByteLen;

class NetworkManager {
  NetworkManager(this.address, this.port);
  final dynamic address;
  final int port;
  Socket socket;
  Stream<List<int>> mStream;
  Int8List cacheData = Int8List(0);
  static ServerSocket serverSocket;

  Future<bool> connect() async {
    try {
      socket = await Socket.connect(
        address,
        port,
        timeout: const Duration(
          seconds: 3,
        ),
      );
      mStream = socket.asBroadcastStream();

      return true;
    } catch (e) {
      print('连接socket出现异常，e=${e.toString()}');
      return false;
    }
  }

  Future<List<int>> getResult() async {
    Completer<List<int>> completer = Completer<List<int>>();
    List<int> tmp = [];
    mStream.listen((event) {
      tmp.addAll(event);
      // Log.e(event);
    }, onDone: () {
      // Log.w('stream down');
      completer.complete(tmp);
    });
    return completer.future;
  }

  Future<String> getString() async {
    Completer<String> completer = Completer<String>();
    List<int> tmp = [];
    mStream.listen((event) {
      tmp.addAll(event);
      // Log.e(event);
    }, onDone: () {
      // Log.w('stream down');
      completer.complete(utf8.decode(tmp));
    });
    return completer.future;
  }

  void sendMsg(String msg) {
    //给服务器发消息
    try {
      socket.add(utf8.encode(msg));
      socket.flush();
    } catch (e) {
      print('e=${e.toString()}');
    }
  }

  void doneHandler() {
    socket.destroy();
  }
}

mixin SocketManage {
  static String host = 'xxx.xxx.xxx.xxx';
  static int port = 80;
  static Socket mSocket;
  static Stream<List<int>> mStream;

  static Future<void> initSocket() async {
    await Socket.connect(host, port).then((Socket socket) {
      mSocket = socket;
      mStream = mSocket.asBroadcastStream(); //多次订阅的流 如果直接用socket.listen只能订阅一次
    }).catchError((dynamic e) {
      initSocket();
    });
  }

  static void addParams(List<int> params) {
    mSocket.add(params);
  }

  static void dispos() {
    mSocket.close();
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class SocketWrapper {
  SocketWrapper(this.address, this.port);
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
      debugPrint('连接socket出现异常，e=${e.toString()}');
      return false;
    }
  }

  Future<SocketWrapper> bind() async {
    try {
      ServerSocket serverSocket = await ServerSocket.bind(
        address,
        port,
      );
      Completer lock = Completer();
      serverSocket.listen((event) {
        socket = event;
        mStream = event.asBroadcastStream();
        lock.complete();
      });
      await lock.future;
      return this;
    } catch (e) {
      debugPrint('连接socket出现异常，e=${e.toString()}');
      return null;
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
      debugPrint('e=${e.toString()}');
    }
  }

  void doneHandler() {
    socket.destroy();
  }
}

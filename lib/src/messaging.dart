import 'dart:async';

import 'package:meta/meta.dart';
import 'package:node_interop/util.dart';

import 'bindings.dart' as js;

class Messaging {
  @protected
  final js.Messaging nativeInstance;

  Messaging(this.nativeInstance);

  Future<String> send(js.Message message) =>
      promiseToFuture(nativeInstance.send(message));

  Future<js.BatchMessageResponse> sendMulticast(js.MulticastMessage message) =>
      promiseToFuture(nativeInstance.sendMulticast(message));

  Future<js.BatchMessageResponse> sendAll(List<js.Message> messages) =>
      promiseToFuture(nativeInstance.sendAll(messages));
}

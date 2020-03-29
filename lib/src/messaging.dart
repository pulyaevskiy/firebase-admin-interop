// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:node_interop/util.dart';

import 'bindings.dart' as js show Messaging;
import 'bindings.dart'
    show
        FcmMessage,
        MulticastMessage,
        MessagingPayload,
        MessagingOptions,
        MessagingDevicesResponse,
        MessagingConditionResponse,
        MessagingDeviceGroupResponse,
        MessagingTopicResponse,
        MessagingTopicManagementResponse,
        BatchResponse;

export 'bindings.dart'
    show
        FcmMessage,
        TopicMessage,
        TokenMessage,
        ConditionMessage,
        MulticastMessage,
        Notification,
        WebpushNotification,
        WebpushFcmOptions,
        WebpushConfig,
        FcmOptions,
        MessagingPayload,
        DataMessagePayload,
        NotificationMessagePayload,
        MessagingOptions,
        MessagingDevicesResponse,
        MessagingDeviceResult,
        MessagingConditionResponse,
        MessagingDeviceGroupResponse,
        MessagingTopicResponse,
        MessagingTopicManagementResponse,
        AndroidConfig,
        AndroidFcmOptions,
        AndroidNotification,
        ApnsConfig,
        ApnsFcmOptions,
        ApnsPayload,
        Aps,
        ApsAlert,
        CriticalSound,
        BatchResponse,
        SendResponse;

class Messaging {
  Messaging(this.nativeInstance);

  @protected
  final js.Messaging nativeInstance;

  /// Sends the given [message] via FCM.
  ///
  /// Returns Future<String> fulfilled with a unique message ID string after the
  /// message has been successfully handed off to the FCM service for delivery
  Future<String> send(FcmMessage message, [bool dryRun]) {
    if (dryRun != null)
      return promiseToFuture(nativeInstance.send(message, dryRun));
    else
      return promiseToFuture(nativeInstance.send(message));
  }

  /// Sends all the [messages] in the given array via Firebase Cloud Messaging.
  ///
  /// Returns Future<BatchResponse> fulfilled with an object representing the
  /// result of the send operation.
  Future<BatchResponse> sendAll(List<FcmMessage> messages, [bool dryRun]) {
    if (dryRun != null)
      return promiseToFuture(nativeInstance.sendAll(messages, dryRun));
    else
      return promiseToFuture(nativeInstance.sendAll(messages));
  }

  /// Sends the given multicast [message] to all the FCM registration tokens
  /// specified in it.
  ///
  /// Returns Future<BatchResponse> fulfilled with an object representing the
  /// result of the send operation.
  Future<BatchResponse> sendMulticast(MulticastMessage message, [bool dryRun]) {
    if (dryRun != null)
      return promiseToFuture(nativeInstance.sendMulticast(message, dryRun));
    else
      return promiseToFuture(nativeInstance.sendMulticast(message));
  }

  /// Sends an FCM message to a [condition].
  ///
  /// Returns Future<MessagingConditionResponse> fulfilled with the server's
  /// response after the message has been sent.
  Future<MessagingConditionResponse> sendToCondition(
      String condition, MessagingPayload payload,
      [MessagingOptions options]) {
    if (options != null)
      return promiseToFuture(
          nativeInstance.sendToCondition(condition, payload, options));
    else
      return promiseToFuture(
          nativeInstance.sendToCondition(condition, payload));
  }

  /// Sends an FCM message to a single device corresponding to the provided
  /// [registrationToken].
  ///
  /// Returns Future<MessagingDevicesResponse> fulfilled with the server's
  /// response after the message has been sent.
  Future<MessagingDevicesResponse> sendToDevice(
      String registrationToken, MessagingPayload payload,
      [MessagingOptions options]) {
    if (options != null)
      return promiseToFuture(
          nativeInstance.sendToDevice(registrationToken, payload, options));
    else
      return promiseToFuture(
          nativeInstance.sendToDevice(registrationToken, payload));
  }

  /// Sends an FCM message to a device group corresponding to the provided
  /// [notificationKey].
  ///
  /// Returns Future<MessagingDevicesResponse> fulfilled with the server's
  /// response after the message has been sent.
  Future<MessagingDeviceGroupResponse> sendToDeviceGroup(
      String notificationKey, MessagingPayload payload,
      [MessagingOptions options]) {
    if (options != null)
      return promiseToFuture(
          nativeInstance.sendToDeviceGroup(notificationKey, payload, options));
    else
      return promiseToFuture(
          nativeInstance.sendToDeviceGroup(notificationKey, payload));
  }

  /// Sends an FCM message to a [topic].
  ///
  /// Returns Future<MessagingTopicResponse> fulfilled with the server's
  /// response after the message has been sent.
  Future<MessagingTopicResponse> sendToTopic(
      String topic, MessagingPayload payload,
      [MessagingOptions options]) {
    if (options != null)
      return promiseToFuture(
          nativeInstance.sendToTopic(topic, payload, options));
    else
      return promiseToFuture(nativeInstance.sendToTopic(topic, payload));
  }

  /// Subscribes a device to an FCM [topic].
  ///
  /// Returns Future<MessagingTopicManagementResponse> fulfilled with the
  /// server's response after the device has been subscribed to the topic.
  Future<MessagingTopicManagementResponse> subscribeToTopic(
          String registrationTokens, String topic) =>
      promiseToFuture(
          nativeInstance.subscribeToTopic(registrationTokens, topic));

  /// Unsubscribes a device from an FCM [topic].
  ///
  /// Returns Future<MessagingTopicManagementResponse> fulfilled with the
  /// server's response after the device has been subscribed to the topic.
  Future<MessagingTopicManagementResponse> unsubscribeFromTopic(
          String registrationTokens, String topic) =>
      promiseToFuture(
          nativeInstance.unsubscribeFromTopic(registrationTokens, topic));
}

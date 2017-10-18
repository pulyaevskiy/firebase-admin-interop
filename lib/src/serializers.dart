// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'database.dart';

/// [Serializers] used by this library.
Serializers get serializers => _serializers;
Serializers _serializers;

/// Registers [serializers] to use by this library.
///
/// Makes Firebase services like Realtime Database and Firestore aware
/// of your application's models and available serializers.
///
/// You are required to register serializers if you intend to use them in
/// calls to [Reference.setValue], [DataSnapshot.val] and others.
void registerSerializers(Serializers serializers) {
  var builder = serializers.toBuilder();
  builder.addPlugin(new StandardJsonPlugin());
  _serializers = builder.build();
}

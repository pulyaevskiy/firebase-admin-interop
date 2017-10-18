// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library values;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'values.g.dart';

abstract class Memo implements Built<Memo, MemoBuilder> {
  static Serializer<Memo> get serializer => _$memoSerializer;
  int get id;
  String get title;
  DateTime get createdAt;

  factory Memo([updates(MemoBuilder b)]) = _$Memo;
  Memo._();
}

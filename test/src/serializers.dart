// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library serializers;

import 'package:built_value/serializer.dart';
import 'values.dart';

part 'serializers.g.dart';

@SerializersFor(const [
  Memo,
])
final Serializers serializers = _$serializers;

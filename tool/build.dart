// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Build tool for build_values example app.
import 'dart:async';

import 'package:build_runner/build_runner.dart';
import 'package:built_value_generator/built_value_generator.dart';
import 'package:source_gen/source_gen.dart';

Future main(List<String> args) async {
  await build([
    new BuildAction(
      new PartBuilder([new BuiltValueGenerator()]),
      'firebase_admin_interop',
      inputs: const [
        'example/src/*.dart',
      ],
    )
  ], deleteFilesByDefault: true);
}

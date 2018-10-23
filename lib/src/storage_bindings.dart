@JS()
library firebase_storage;

import "package:js/js.dart";
import 'package:node_interop/node.dart';

import 'bindings.dart';

/// The Cloud Storage service interface.
@JS()
@anonymous
abstract class Storage {
  /// The app associated with this Storage instance.
  external App get app;

  /// Returns a reference to a Google Cloud Storage bucket.
  ///
  /// Returned reference can be used to upload and download content from
  /// Google Cloud Storage.
  ///
  /// [name] of the bucket to be retrieved is optional. If [name] is not
  /// specified, retrieves a reference to the default bucket.
  external Bucket bucket([String name]);
}

@JS()
@anonymous
abstract class Bucket {
  /// Combine multiple files into one new file.
  ///
  /// [sources] can be a list of strings or [StorageFile]s.
  /// [destination] can be a string or [StorageFile].
  ///
  /// Returns promise containing list with following values:
  /// [0] [StorageFile] - The new file.
  /// [1] [Object]      - The full API response.
  external Promise combine(List sources, dynamic destination,
      [options, callback]);

  /// Create a bucket.
  ///
  /// Returns promise containing CreateBucketResponse.
  external Promise create([CreateBucketRequest metadata, callback]);

  /// Checks if the bucket exists.
  ///
  /// Returns promise containing list with following values:
  /// [0] [boolean] - Whether this bucket exists.
  external Promise exists([BucketExistsOptions options, callback]);

  /// Creates a [StorageFile] object.
  ///
  /// See [StorageFile] to see for more details.
  external StorageFile file(String name, [StorageFileOptions options]);

  /// Upload a file to the bucket. This is a convenience method that wraps
  /// [StorageFile.createWriteStream].
  ///
  /// [path] is the fully qualified path to the file you wish to upload to your
  /// bucket.
  ///
  /// You can specify whether or not an upload is resumable by setting
  /// `options.resumable`. Resumable uploads are enabled by default if your
  /// input file is larger than 5 MB.
  ///
  /// For faster crc32c computation, you must manually install `fast-crc32c`:
  ///
  ///     npm install --save fast-crc32c
  external Promise upload(String pathString, [options, callback]);
}

@JS()
@anonymous
abstract class CombineOptions {
  /// Resource name of the Cloud KMS key that will be used to encrypt the
  /// object.
  ///
  /// Overwrites the object metadata's kms_key_name value, if any.
  external String get kmsKeyName;

  /// The ID of the project which will be billed for the request.
  external String get userProject;

  external factory CombineOptions({String kmsKeyName, String userProject});
}

@JS()
@anonymous
abstract class CreateBucketRequest {
  // TODO: complete
}

@JS()
@anonymous
abstract class BucketExistsOptions {
  /// The ID of the project which will be billed for the request.
  external String get userProject;

  external factory BucketExistsOptions({String userProject});
}

@JS()
@anonymous
abstract class StorageFileOptions {
  /// Only use a specific revision of this file.
  external String get generation;

  /// A custom encryption key.
  external String get encryptionKey;

  /// Resource name of the Cloud KMS key that will be used to encrypt the
  /// object.
  ///
  /// Overwrites the object metadata's kms_key_name value, if any.
  external String get kmsKeyName;

  external factory StorageFileOptions(
      {String generation, String encryptionKey, String kmsKeyName});
}

@JS()
@anonymous
abstract class StorageFile {}

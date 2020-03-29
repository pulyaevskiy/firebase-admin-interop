// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
@JS()
library firebase_admin;

import 'package:js/js.dart';
import 'package:node_interop/node.dart';

import 'firestore_bindings.dart' show Firestore, GeoPointUtil, FieldValues;

export 'firestore_bindings.dart';

// admin =========================================================================

const defaultAppName = '[DEFAULT]';

/// Singleton instance of [FirebaseAdmin] module.
final FirebaseAdmin admin = require('firebase-admin');

@JS()
@anonymous
abstract class FirebaseAdmin {
  /// Creates and initializes a Firebase app instance.
  external App initializeApp([options, String name]);

  /// The current SDK version.
  external String get SDK_VERSION;

  /// A (read-only) array of all initialized apps.
  external List<App> get apps;

  /// Retrieves a Firebase [App] instance.
  ///
  /// When called with no arguments, the default app is returned. When an app
  /// [name] is provided, the app corresponding to that name is returned.
  ///
  /// An exception is thrown if the app being retrieved has not yet been
  /// initialized.
  external App app([String name]);

  /// Gets the [Auth] service for the default app or a given [app].
  external Auth auth([App app]);

  /// Gets the [Database] service for the default app or a given [app].
  external DatabaseService get database;

  /// Gets the [Firestore] client for the default app or a given [app].
  external FirestoreService get firestore;

  external Credentials get credential;

  /// Gets the [Messaging] service for the default app or a given [app].
  external Messaging messaging([App app]);
}

@JS()
@anonymous
abstract class FirebaseError implements JsError {
  /// Error codes are strings using the following format:
  /// "service/string-code". Some examples include "auth/invalid-uid" and
  /// "messaging/invalid-recipient".
  ///
  /// While the message for a given error can change, the code will remain the
  /// same between backward-compatible versions of the Firebase SDK.
  external String get code;
}

@JS()
@anonymous
abstract class FirebaseArrayIndexError {
  external FirebaseError get error;
  external num get index;
}

// admin.credential ============================================================

@JS()
@anonymous
abstract class Credentials {
  /// Returns a [Credential] created from the Google Application Default
  /// Credentials (ADC) that grants admin access to Firebase services.
  ///
  /// This credential can be used in the call to [initializeApp].
  external Credential applicationDefault();

  /// Returns [Credential] created from the provided service account that grants
  /// admin access to Firebase services.
  ///
  /// This credential can be used in the call to [initializeApp].
  /// [credentials] must be a path to a service account key JSON file or an
  /// object representing a service account key.
  external Credential cert(credentials);

  /// Returns [Credential] created from the provided refresh token that grants
  /// admin access to Firebase services.
  ///
  /// This credential can be used in the call to [initializeApp].
  external Credential refreshToken(refreshTokenPathOrObject);
}

@JS()
@anonymous
abstract class ServiceAccountConfig {
  external String get project_id;
  external String get client_email;
  external String get private_key;

  external factory ServiceAccountConfig(
      {String project_id, String client_email, String private_key});
}

/// Interface which provides Google OAuth2 access tokens used to authenticate
/// with Firebase services.
@JS()
@anonymous
abstract class Credential {
  /// Returns a Google OAuth2 [AccessToken] object used to authenticate with
  /// Firebase services.
  external AccessToken getAccessToken();
}

/// Google OAuth2 access token object used to authenticate with Firebase
/// services.
@JS()
@anonymous
abstract class AccessToken {
  /// The actual Google OAuth2 access token.
  external String get access_token;

  /// The number of seconds from when the token was issued that it expires.
  external num get expires_in;
}

// admin.app ===================================================================

/// A Firebase app holds the initialization information for a collection of
/// services.
@JS()
@anonymous
abstract class App {
  /// The name for this app.
  ///
  /// The default app's name is `[DEFAULT]`.
  external String get name;

  /// The (read-only) configuration options for this app. These are the original
  /// parameters given in [initializeApp].
  external AppOptions get options;

  /// Gets the [Auth] service for this app.
  external Auth auth();

  /// Gets the [Database] service for this app.
  external Database database();

  /// Renders this app unusable and frees the resources of all associated
  /// services.
  external Promise delete();

  /// Gets the [Firestore] client for this app.
  external Firestore firestore();

  /// Gets the [Messaging] service for this app.
  external Messaging messaging();
}

/// Available options to pass to [initializeApp].
@JS()
@anonymous
abstract class AppOptions {
  /// A [Credential] object used to authenticate the Admin SDK.
  ///
  /// You can obtain a credential via one of the following methods:
  ///
  /// - [applicationDefaultCredential]
  /// - [cert]
  /// - [refreshToken]
  external Credential get credential;

  /// The URL of the Realtime Database from which to read and write data.
  external String get databaseURL;

  /// The ID of the Google Cloud project associated with the App.
  external String get projectId;

  /// The name of the default Cloud Storage bucket associated with the App.
  external String get storageBucket;

  /// Creates new instance of [AppOptions].
  external factory AppOptions({
    Credential credential,
    String databaseURL,
    String projectId,
    String storageBucket,
  });
}

// admin.auth ==================================================================

/// The Firebase Auth service interface.
@JS()
@anonymous
abstract class Auth {
  /// The app associated with this Auth service instance.
  external App get app;

  /// Creates a new Firebase custom token (JWT) that can be sent back to a client
  /// device to use to sign in with the client SDKs' signInWithCustomToken()
  /// methods.
  ///
  /// Returns a promise fulfilled with a custom token string for the provided uid
  /// and payload.
  external Promise createCustomToken(String uid, developerClaims);

  /// Creates a new user.
  ///
  /// Returns a promise fulfilled with [UserRecord] corresponding to the newly
  /// created user.
  external Promise createUser(CreateUserRequest properties);

  /// Deletes an existing user.
  ///
  /// Returns a promise containing `void`.
  external Promise deleteUser(String uid);

  /// Gets the user data for the user corresponding to a given [uid].
  ///
  /// Returns a promise fulfilled with [UserRecord] corresponding to the provided
  /// [uid].
  external Promise getUser(String uid);

  /// Gets the user data for the user corresponding to a given [email].
  ///
  /// Returns a promise fulfilled with [UserRecord] corresponding to the provided
  /// [email].
  external Promise getUserByEmail(String email);

  /// Gets the user data for the user corresponding to a given [phoneNumber].
  ///
  /// Returns a promise fulfilled with [UserRecord] corresponding to the provided
  /// [phoneNumber].
  external Promise getUserByPhoneNumber(String phoneNumber);

  /// Retrieves a list of users (single batch only) with a size of [maxResults]
  /// and starting from the offset as specified by [pageToken].
  ///
  /// This is used to retrieve all the users of a specified project in batches.
  ///
  /// Returns a promise that resolves with the current batch of downloaded users
  /// and the next page token as an instance of [ListUsersResult].
  external Promise listUsers([num maxResults, String pageToken]);

  /// Revokes all refresh tokens for an existing user.
  ///
  /// This API will update the user's [UserRecord.tokensValidAfterTime] to the
  /// current UTC. It is important that the server on which this is called has
  /// its clock set correctly and synchronized.
  ///
  /// While this will revoke all sessions for a specified user and disable any
  /// new ID tokens for existing sessions from getting minted, existing ID tokens
  /// may remain active until their natural expiration (one hour). To verify that
  /// ID tokens are revoked, use [Auth.verifyIdToken] where `checkRevoked` is set
  /// to `true`.
  ///
  /// Returns a promise containing `void`.
  external Promise revokeRefreshTokens(String uid);

  /// Sets additional developer claims on an existing user identified by the
  /// provided uid, typically used to define user roles and levels of access.
  ///
  /// These claims should propagate to all devices where the user is already
  /// signed in (after token expiration or when token refresh is forced) and the
  /// next time the user signs in. If a reserved OIDC claim name is used
  /// (sub, iat, iss, etc), an error is thrown. They will be set on the
  /// authenticated user's ID token JWT.
  ///
  /// [customUserClaims] can be `null`.
  ///
  /// Returns a promise containing `void`.
  external Promise setCustomUserClaims(String uid, customUserClaims);

  /// Updates an existing user.
  ///
  /// Returns a promise containing updated [UserRecord].
  external Promise updateUser(String uid, UpdateUserRequest properties);

  /// Verifies a Firebase ID token (JWT).
  ///
  /// If the token is valid, the returned promise is fulfilled with an instance of
  /// [DecodedIdToken]; otherwise, the promise is rejected. An optional flag can
  /// be passed to additionally check whether the ID token was revoked.
  external Promise verifyIdToken(String idToken, [bool checkRevoked]);
}

@JS()
@anonymous
abstract class CreateUserRequest {
  external bool get disabled;
  external String get displayName;
  external String get email;
  external bool get emailVerified;
  external String get password;
  external String get phoneNumber;
  external String get photoURL;
  external String get uid;

  external factory CreateUserRequest({
    bool disabled,
    String displayName,
    String email,
    bool emailVerified,
    String password,
    String phoneNumber,
    String photoURL,
    String uid,
  });
}

@JS()
@anonymous
abstract class UpdateUserRequest {
  external bool get disabled;
  external String get displayName;
  external String get email;
  external bool get emailVerified;
  external String get password;
  external String get phoneNumber;
  external String get photoURL;

  external factory UpdateUserRequest({
    bool disabled,
    String displayName,
    String email,
    bool emailVerified,
    String password,
    String phoneNumber,
    String photoURL,
  });
}

/// Interface representing a user.
@JS()
@anonymous
abstract class UserRecord {
  /// The user's custom claims object if available, typically used to define user
  /// roles and propagated to an authenticated user's ID token.
  ///
  /// This is set via [Auth.setCustomUserClaims].
  external get customClaims;

  /// Whether or not the user is disabled: true for disabled; false for enabled.
  external bool get disabled;

  /// The user's display name.
  external String get displayName;

  /// The user's primary email, if set.
  external String get email;

  /// Whether or not the user's primary email is verified.
  external bool get emailVerified;

  /// Additional metadata about the user.
  external UserMetadata get metadata;

  /// The user’s hashed password (base64-encoded), only if Firebase Auth hashing
  /// algorithm (SCRYPT) is used.
  ///
  /// If a different hashing algorithm had been used when uploading this user,
  /// typical when migrating from another Auth system, this will be an empty
  /// string. If no password is set, this will be`null`.
  ///
  /// This is only available when the user is obtained from [Auth.listUsers].
  external String get passwordHash;

  /// The user’s password salt (base64-encoded), only if Firebase Auth hashing
  /// algorithm (SCRYPT) is used.
  ///
  /// If a different hashing algorithm had been used to upload this user, typical
  /// when migrating from another Auth system, this will be an empty string.
  /// If no password is set, this will be `null`.
  ///
  /// This is only available when the user is obtained from [Auth.listUsers].
  external String get passwordSalt;

  /// The user's primary phone number or `null`.
  external String get phoneNumber;

  /// The user's photo URL or `null`.
  external String get photoURL;

  /// An array of providers (for example, Google, Facebook) linked to the user.
  external List<UserInfo> get providerData;

  /// The date the user's tokens are valid after, formatted as a UTC string.
  ///
  /// This is updated every time the user's refresh token are revoked either from
  /// the [Auth.revokeRefreshTokens] API or from the Firebase Auth backend on big
  /// account changes (password resets, password or email updates, etc).
  external String get tokensValidAfterTime;

  /// The user's uid.
  external String get uid;

  external dynamic toJSON();
}

@JS()
@anonymous
abstract class UserMetadata {
  /// The date the user was created, formatted as a UTC string.
  external String get creationTime;

  /// The date the user last signed in, formatted as a UTC string.
  external String get lastSignInTime;
}

/// Interface representing a user's info from a third-party identity provider
/// such as Google or Facebook.
@JS()
@anonymous
abstract class UserInfo {
  /// The display name for the linked provider.
  external String get displayName;

  /// The email for the linked provider.
  external String get email;

  /// The phone number for the linked provider.
  external String get phoneNumber;

  /// The photo URL for the linked provider.
  external String get photoURL;

  /// The linked provider ID (for example, "google.com" for the Google provider).
  external String get providerId;

  /// The user identifier for the linked provider.
  external String get uid;

  external dynamic toJSON();
}

/// Interface representing a resulting object returned from a [Auth.listUsers]
/// operation containing the list of users for the current batch and the next
/// page token if available.
@JS()
@anonymous
abstract class ListUsersResult {
  external String get pageToken;
  external List<UserRecord> get users;
}

/// Interface representing a decoded Firebase ID token, returned from the
/// [Auth.verifyIdToken] method.
@JS()
@anonymous
abstract class DecodedIdToken {
  /// The audience for which this token is intended.
  ///
  /// This value is a string equal to your Firebase project ID, the unique
  /// identifier for your Firebase project, which can be found in your project's
  /// settings.
  external String get aud;

  /// Time, in seconds since the Unix epoch, when the end-user authentication
  /// occurred.
  ///
  /// This value is not when this particular ID token was created, but when the
  /// user initially logged in to this session. In a single session, the Firebase
  /// SDKs will refresh a user's ID tokens every hour. Each ID token will have a
  /// different [iat] value, but the same auth_time value.
  external num get auth_time;

  /// The ID token's expiration time, in seconds since the Unix epoch.
  ///
  /// That is, the time at which this ID token expires and should no longer be
  /// considered valid.
  ///
  /// The Firebase SDKs transparently refresh ID tokens every hour, issuing a new
  /// ID token with up to a one hour expiration.
  external num get exp;

  /// Information about the sign in event, including which sign in provider was
  /// used and provider-specific identity details.
  ///
  /// This data is provided by the Firebase Authentication service and is a
  /// reserved claim in the ID token.
  external FirebaseSignInInfo get firebase;

  /// The ID token's issued-at time, in seconds since the Unix epoch.
  ///
  /// That is, the time at which this ID token was issued and should start to
  /// be considered valid.
  ///
  /// The Firebase SDKs transparently refresh ID tokens every hour, issuing a new
  /// ID token with a new issued-at time. If you want to get the time at which
  /// the user session corresponding to the ID token initially occurred, see the
  /// [auth_time] property.
  external num get iat;

  /// The issuer identifier for the issuer of the response.
  ///
  /// This value is a URL with the format
  /// `https://securetoken.google.com/<PROJECT_ID>`, where <PROJECT_ID> is the
  /// same project ID specified in the [aud] property.
  external String get iss;

  /// The uid corresponding to the user who the ID token belonged to.
  ///
  /// As a convenience, this value is copied over to the [uid] property.
  external String get sub;

  /// The uid corresponding to the user who the ID token belonged to.
  ///
  /// This value is not actually in the JWT token claims itself. It is added as a
  /// convenience, and is set as the value of the [sub] property.
  external String get uid;
}

@JS()
@anonymous
abstract class FirebaseSignInInfo {
  /// Provider-specific identity details corresponding to the provider used to
  /// sign in the user.
  external get identities;

  /// The ID of the provider used to sign in the user. One of "anonymous",
  /// "password", "facebook.com", "github.com", "google.com", "twitter.com",
  /// or "custom".
  external String get sign_in_provider;
}

// admin.firestore ===============================================================

@JS()
@anonymous
abstract class FirestoreService {
  external GeoPointUtil get GeoPoint;
  external FieldValues get FieldValue;
  external dynamic get Timestamp;
  external dynamic get FieldPath;
}

// admin.messaging ================================================================

/// The Firebase Messaging service interface.
@JS()
@anonymous
abstract class Messaging {
  /// The app associated with this Messaging service instance.
  external App get app;

  /// Sends the given message via FCM.
  ///
  /// Returns Promise<string> fulfilled with a unique message ID string after the
  /// message has been successfully handed off to the FCM service for delivery
  external Promise send(FcmMessage message, [bool dryRun]);

  /// Sends all the messages in the given array via Firebase Cloud Messaging.
  ///
  /// Returns Promise<BatchResponse> fulfilled with an object representing the
  /// result of the send operation.
  external Promise sendAll(List<FcmMessage> messages, [bool dryRun]);

  /// Sends the given multicast message to all the FCM registration tokens
  /// specified in it.
  ///
  /// Returns Promise<BatchResponse> fulfilled with an object representing the
  /// result of the send operation.
  external Promise sendMulticast(MulticastMessage message, [bool dryRun]);

  /// Sends an FCM message to a condition.
  ///
  /// Returns Promise<MessagingConditionResponse> fulfilled with the server's
  /// response after the message has been sent.
  external Promise sendToCondition(String condition, MessagingPayload payload,
      [MessagingOptions options]);

  /// Sends an FCM message to a single device corresponding to the provided
  /// registration token.
  ///
  /// Returns Promise<MessagingDevicesResponse> fulfilled with the server's
  /// response after the message has been sent.
  external Promise sendToDevice(
      String registrationToken, MessagingPayload payload,
      [MessagingOptions options]);

  /// Sends an FCM message to a device group corresponding to the provided
  /// notification key.
  ///
  /// Returns Promise<MessagingDevicesResponse> fulfilled with the server's
  /// response after the message has been sent.
  external Promise sendToDeviceGroup(
      String notificationKey, MessagingPayload payload,
      [MessagingOptions options]);

  /// Sends an FCM message to a topic.
  ///
  /// Returns Promise<MessagingTopicResponse> fulfilled with the server's
  /// response after the message has been sent.
  external Promise sendToTopic(String topic, MessagingPayload payload,
      [MessagingOptions options]);

  /// Subscribes a device to an FCM topic.
  ///
  /// Returns Promise<MessagingTopicManagementResponse> fulfilled with the
  /// server's response after the device has been subscribed to the topic.
  external Promise subscribeToTopic(String registrationTokens, String topic);

  /// Unsubscribes a device from an FCM topic.
  ///
  /// Returns Promise<MessagingTopicManagementResponse> fulfilled with the
  /// server's response after the device has been subscribed to the topic.
  external Promise unsubscribeFromTopic(
      String registrationTokens, String topic);
}

@JS()
@anonymous
abstract class FcmMessage {
  external String get data;
  external Notification get notification;
  external String get token;

  external factory FcmMessage({
    String data,
    Notification notification,
    String token,
  });
}

@JS()
@anonymous
abstract class TopicMessage {
  external AndroidConfig get android;
  external ApnsConfig get apns;
  external dynamic get data;
  external String get key;
  external FcmOptions get fcmOptions;
  external Notification get notification;

  /// Required
  external String get topic;
  external WebpushConfig get webpush;

  external factory TopicMessage({
    AndroidConfig android,
    ApnsConfig apns,
    dynamic data,
    String key,
    FcmOptions fcmOptions,
    Notification notification,
    String topic,
    WebpushConfig webpush,
  });
}

@JS()
@anonymous
abstract class TokenMessage {
  external AndroidConfig get android;
  external ApnsConfig get apns;
  external dynamic get data;
  external String get key;
  external FcmOptions get fcmOptions;
  external Notification get notification;

  /// Required
  external String get token;
  external WebpushConfig get webpush;

  external factory TokenMessage({
    AndroidConfig android,
    ApnsConfig apns,
    dynamic data,
    String key,
    FcmOptions fcmOptions,
    Notification notification,
    String token,
    WebpushConfig webpush,
  });
}

@JS()
@anonymous
abstract class ConditionMessage {
  external AndroidConfig get android;
  external ApnsConfig get apns;

  /// Required
  external String get condition;
  external dynamic get data;
  external String get key;
  external FcmOptions get fcmOptions;
  external Notification get notification;
  external WebpushConfig get webpush;

  external factory ConditionMessage({
    AndroidConfig android,
    ApnsConfig apns,
    String condition,
    dynamic data,
    String key,
    FcmOptions fcmOptions,
    Notification notification,
    WebpushConfig webpush,
  });
}

@JS()
@anonymous
abstract class MulticastMessage {
  external AndroidConfig get android;
  external ApnsConfig get apns;
  external dynamic get data;
  external String get key;
  external FcmOptions get fcmOptions;
  external Notification get notification;

  /// Required
  external List<String> get tokens;
  external WebpushConfig get webpush;

  external factory MulticastMessage({
    AndroidConfig android,
    ApnsConfig apns,
    dynamic data,
    String key,
    FcmOptions fcmOptions,
    Notification notification,
    List<String> tokens,
    WebpushConfig webpush,
  });
}

/// A notification that can be included in admin.messaging.Message.
@JS()
@anonymous
abstract class Notification {
  /// The notification body
  external String get body;

  /// URL of an image to be displayed in the notification.
  external String get imageUrl;

  /// The title of the notification.
  external String get title;

  external factory Notification({
    String body,
    String imageUrl,
    String title,
  });
}

/// Represents the WebPush-specific notification options that can be included
/// in admin.messaging.WebpushConfig.
@JS()
@anonymous
abstract class WebpushNotification {
  /// An array of notification actions representing the actions available to
  /// the user when the notification is presented.
  external List<dynamic> get actions;

  /// URL of the image used to represent the notification when there is not
  /// enough space to display the notification itself.
  external String get badge;

  /// Body text of the notification.
  external String get body;

  /// Arbitrary data that you want associated with the notification. This can
  /// be of any data type.
  external dynamic get data;

  /// The direction in which to display the notification. Must be one of auto,
  /// ltr or rtl.
  external String get dir;

  /// URL to the notification icon.
  external String get icon;

  /// URL of an image to be displayed in the notification.
  external String get image;

  /// The notification's language as a BCP 47 language tag.
  external String get lang;

  /// A boolean specifying whether the user should be notified after a new
  /// notification replaces an old one. Defaults to false.
  external bool get renotify;

  /// Indicates that a notification should remain active until the user clicks
  /// or dismisses it, rather than closing automatically.
  ///
  /// Defaults to false.
  external bool get requireInteraction;

  /// A boolean specifying whether the notification should be silent.
  ///
  /// Defaults to false.
  external bool get silent;

  /// An identifying tag for the notification.
  external String get tag;

  /// Timestamp of the notification
  external num get timestamp;

  /// Title text of the notification.
  external String get title;

  /// A vibration pattern for the device's vibration hardware to emit when the
  /// notification fires.
  external num get vibrate;

  external factory WebpushNotification({
    List<dynamic> actions,
    String badge,
    String body,
    dynamic data,
    String dir,
    String icon,
    String image,
    String lang,
    bool renotify,
    bool requireInteraction,
    bool silent,
    String tag,
    num timestamp,
    String title,
    num vibrate,
  });
}

/// Represents the WebPush protocol options that can be included in an
/// admin.messaging.Message.
@JS()
@anonymous
abstract class WebpushConfig {
  /// A collection of data fields.
  external dynamic get data;

  /// Options for features provided by the FCM SDK for Web.
  external FcmOptions get fcmOptions;

  /// A collection of WebPush headers. Header values must be strings.
  external dynamic get headers;

  /// A WebPush notification payload to be included in the message.
  external WebpushNotification get notification;

  external factory WebpushConfig({
    dynamic data,
    FcmOptions fcmOptions,
    dynamic headers,
    WebpushNotification notification,
  });
}

/// Represents options for features provided by the FCM SDK for Web (which are
/// not part of the Webpush standard).
@JS()
@anonymous
abstract class WebpushFcmOptions {
  /// The link to open when the user clicks on the notification. For all URL
  /// values, HTTPS is required.
  external String get link;

  external factory WebpushFcmOptions({
    String link,
  });
}

/// Options for features provided by the FCM SDK for Web.
@JS()
@anonymous
abstract class FcmOptions {
  /// The label associated with the message's analytics data.
  external String get analyticsLabel;

  external factory FcmOptions({
    String analyticsLabel,
  });
}

/// Interface representing a Firebase Cloud Messaging message payload. One or
/// both of the data and notification keys are required.
@JS()
@anonymous
abstract class MessagingPayload {
  /// The data message payload.
  external DataMessagePayload get data;

  /// The notification message payload.
  external NotificationMessagePayload get notification;

  external factory MessagingPayload({
    DataMessagePayload data,
    NotificationMessagePayload notification,
  });
}

/// Interface representing an FCM legacy API data message payload.
///
/// Data messages let developers send up to 4KB of custom key-value pairs.
/// The keys and values must both be strings.
@JS()
@anonymous
abstract class DataMessagePayload {
  /// Keys can be any custom string, except for the following reserved strings:
  /// "from" and anything starting with "google."
  external String get key;
  external dynamic get value;

  external factory DataMessagePayload({
    String key,
    dynamic value,
  });
}

/// Interface representing an FCM legacy API notification message payload.
/// Notification messages let developers send up to 4KB of predefined key-value
/// pairs.
@JS()
@anonymous
abstract class NotificationMessagePayload {
  /// An array of notification actions representing the actions available to
  /// the user when the notification is presented.
  external List<dynamic> get actions;

  /// URL of the image used to represent the notification when there is not
  /// enough space to display the notification itself.
  external String get badge;

  /// Body text of the notification.
  external String get body;

  /// Variable string values to be used in place of the format specifiers in
  /// body_loc_key to use to localize the body text to the user's current
  /// localization.
  ///
  /// The value should be a stringified JSON array.
  external String get bodyLocArgs;

  /// The key to the body string in the app's string resources to use to
  /// localize the body text to the user's current localization.
  external String get bodyLocKey;

  /// Action associated with a user click on the notification. If specified,
  /// an activity with a matching Intent Filter is launched when a user clicks
  /// on the notification.
  external String get clickAction;

  /// The notification icon's color, expressed in #rrggbb format.
  external String get color;

  /// URL to the notification icon.
  external String get icon;

  /// Identifier used to replace existing notifications in the notification
  /// drawer.
  external String get sound;

  /// An identifying tag for the notification.
  external String get tag;

  /// The notification's title.
  external String get title;

  /// Variable string values to be used in place of the format specifiers in
  /// title_loc_key to use to localize the title text to the user's current
  /// localization. The value should be a stringified JSON array.
  external String get titleLocArgs;

  /// The key to the title string in the app's string resources to use to
  /// localize the title text to the user's current localization.
  external String get titleLocKey;

  external factory NotificationMessagePayload({
    List<dynamic> actions,
    String badge,
    String body,
    String bodyLocArgs,
    String bodyLocKey,
    String clickAction,
    String color,
    String icon,
    String sound,
    String tag,
    String title,
    String titleLocArgs,
    String titleLocKey,
  });
}

/// Interface representing the options that can be provided when sending a
/// message via the FCM legacy APIs.
@JS()
@anonymous
abstract class MessagingOptions {
  /// String identifying a group of messages (for example, "Updates Available")
  /// that can be collapsed, so that only the last message gets sent when
  /// delivery can be resumed. This is used to avoid sending too many of the
  /// same messages when the device comes back online or becomes active.
  external String get collapseKey;

  /// On iOS, use this field to represent content-available in the APNs payload.
  ///
  /// When a notification or data message is sent and this is set to true,
  /// an inactive client app is awoken. On Android, data messages wake the app
  /// by default. On Chrome, this flag is currently not supported.
  external bool get contentAvailable;

  /// Whether or not the message should actually be sent.
  ///
  /// When set to true, allows developers to test a request without actually
  /// sending a message. When set to false, the message will be sent.
  external bool get dryRun;

  /// On iOS, use this field to represent mutable-content in the APNs payload.
  ///
  /// When a notification is sent and this is set to true, the content of the
  /// notification can be modified before it is displayed, using a Notification
  /// Service app extension. On Android and Web, this parameter will be ignored.
  external bool get mutableContent;

  /// The priority of the message. Valid values are "normal" and "high".
  ///
  /// On iOS, these correspond to APNs priorities 5 and 10.
  external String get priority;

  /// The package name of the application which the registration tokens must
  /// match in order to receive the message.
  external String get restrictedPackageName;

  /// How long (in seconds) the message should be kept in FCM storage if the
  /// device is offline.
  ///
  /// The maximum time to live supported is four weeks, and the default value
  /// is also four weeks.
  external num get timeToLive;

  external factory MessagingOptions({
    String collapseKey,
    bool contentAvailable,
    bool dryRun,
    bool mutableContent,
    String priority,
    String restrictedPackageName,
    num timeToLive,
  });
}

/// Represents the Android-specific options that can be included in an
/// admin.messaging.Message.
@JS()
@anonymous
abstract class AndroidConfig {
  /// Collapse key for the message.
  ///
  /// Collapse key serves as an identifier for a group of messages that can be
  /// collapsed, so that only the last message gets sent when delivery can be
  /// resumed. A maximum of four different collapse keys may be active at any
  /// given time.
  external String get collapseKey;

  /// A collection of data fields to be included in the message.
  ///
  /// All values must be strings. When provided, overrides any data fields
  /// set on the top-level admin.messaging.Message.
  external dynamic get data;

  /// Options for features provided by the FCM SDK for Android.
  external AndroidFcmOptions get fcmOptions;

  /// Android notification to be included in the message.
  external AndroidNotification get notification;

  /// Priority of the message. Must be either normal or high.
  external String get priority;

  /// Package name of the application where the registration tokens must match
  /// in order to receive the message.
  external String get restrictedPackageName;

  /// Time-to-live duration of the message in milliseconds.
  external num get ttl;

  external factory AndroidConfig({
    String collapseKey,
    dynamic data,
    AndroidFcmOptions fcmOptions,
    AndroidNotification notification,
    String priority,
    String restrictedPackageName,
    num ttl,
  });
}

/// Represents options for features provided by the FCM SDK for Android.
@JS()
@anonymous
abstract class AndroidFcmOptions {
  /// The label associated with the message's analytics data.
  external String get analyticsLabel;

  external factory AndroidFcmOptions({
    String analyticsLabel,
  });
}

/// Represents the Android-specific notification options that can be included
/// in admin.messaging.AndroidConfig.
@JS()
@anonymous
abstract class AndroidNotification {
  /// Body of the Android notification. When provided, overrides the body set
  /// via admin.messaging.Notification
  external String get body;

  /// An array of resource keys that will be used in place of the format
  /// specifiers in bodyLocKey.
  external List<String> get bodyLocArgs;

  /// The key to the body string in the app's string resources to use to
  /// localize the body text to the user's current localization.
  external String get bodyLocKey;

  /// The Android notification channel ID (new in Android O).
  external String get channelId;

  /// Action associated with a user click on the notification.
  ///
  /// If specified, an activity with a matching Intent Filter is launched when
  /// a user clicks on the notification.
  external String get clickAction;

  /// Notification icon color in #rrggbb format.
  external String get color;

  /// Icon resource for the Android notification.
  external String get icon;

  /// URL of an image to be displayed in the notification.
  external String get imageUrl;

  /// File name of the sound to be played when the device receives the
  /// notification.
  external String get sound;

  /// Notification tag.
  ///
  /// This is an identifier used to replace existing notifications in the
  /// notification drawer. If not specified, each request creates a new
  /// notification.
  external String get tag;

  /// Title of the Android notification. When provided, overrides the title set
  /// via admin.messaging.Notification.
  external String get title;

  /// An array of resource keys that will be used in place of the format
  /// specifiers in titleLocKey.
  external List<String> get titleLocArgs;

  /// Key of the title string in the app's string resource to use to localize
  /// the title text.
  external String get titleLocKey;

  external factory AndroidNotification({
    String body,
    List<String> bodyLocArgs,
    String bodyLocKey,
    String channelId,
    String clickAction,
    String color,
    String icon,
    String imageUrl,
    String sound,
    String tag,
    String title,
    List<String> titleLocArgs,
    String titleLocKey,
  });
}

/// Represents the APNs-specific options that can be included in an
/// admin.messaging.Message.
@JS()
@anonymous
abstract class ApnsConfig {
  /// Options for features provided by the FCM SDK for iOS.
  external ApnsFcmOptions get fcmOptions;

  /// A collection of APNs headers. Header values must be strings.
  external dynamic get headers;

  /// An APNs payload to be included in the message.
  external ApnsPayload get payload;

  external factory ApnsConfig({
    ApnsFcmOptions fcmOptions,
    dynamic headers,
    ApnsPayload payload,
  });
}

/// Represents options for features provided by the FCM SDK for iOS.
@JS()
@anonymous
abstract class ApnsFcmOptions {
  /// The label associated with the message's analytics data.
  external String get analyticsLabel;

  /// URL of an image to be displayed in the notification.
  external String get imageUrl;

  external factory ApnsFcmOptions({String analyticsLabel, String imageUrl});
}

/// Represents options for features provided by the FCM SDK for iOS.
@JS()
@anonymous
abstract class ApnsPayload {
  /// The aps dictionary to be included in the message.
  external Aps get aps;

  external factory ApnsPayload({
    Aps aps,
  });
}

/// Represents the aps dictionary that is part of APNs messages.
@JS()
@anonymous
abstract class Aps {
  /// Alert to be included in the message. This may be a string or an object of
  /// type admin.messaging.ApsAlert
  external String get alert;

  /// Badge to be displayed with the message.
  ///
  /// Set to 0 to remove the badge. When not specified, the badge will remain
  /// unchanged.
  external num get badge;

  /// Type of the notification.
  external String get category;

  /// Specifies whether to configure a background update notification.
  external bool get contentAvailable;

  /// Specifies whether to set the mutable-content property on the message so
  /// the clients can modify the notification via app extensions.
  external bool get mutableContent;

  /// Sound to be played with the message.
  external String get sound;

  /// An app-specific identifier for grouping notifications.
  external String get threadId;

  external factory Aps({
    String alert,
    num badge,
    String category,
    bool contentAvailable,
    bool mutableContent,
    String sound,
  });
}

@JS()
@anonymous
abstract class ApsAlert {
  external String get actionLocKey;
  external String get body;
  external String get launchImage;
  external List<String> get locArgs;
  external String get locKey;
  external String get subtitle;
  external List<String> get subtitleLocArgs;
  external String get subtitleLocKey;
  external String get title;
  external List<String> get titleLocArgs;
  external String get titleLocKey;

  external factory ApsAlert({
    String actionLocKey,
    String body,
    String launchImage,
    List<String> locArgs,
    String locKey,
    String subtitle,
    List<String> subtitleLocArgs,
    String subtitleLocKey,
    String title,
    List<String> titleLocArgs,
    String titleLocKey,
  });
}

/// Represents a critical sound configuration that can be included in the aps
/// dictionary of an APNs payload.
@JS()
@anonymous
abstract class CriticalSound {
  /// The critical alert flag. Set to true to enable the critical alert.
  external bool get critical;

  /// The name of a sound file in the app's main bundle or in the
  /// Library/Sounds folder of the app's container directory.
  ///
  /// Specify the string "default" to play the system sound.
  external String get name;

  /// The volume for the critical alert's sound.
  ///
  /// Must be a value between 0.0 (silent) and 1.0 (full volume).
  external num get volume;

  external factory CriticalSound({
    bool critical,
    String name,
    num volume,
  });
}

/// Interface representing the server response from the sendAll() and
/// sendMulticast() methods.
@JS()
@anonymous
abstract class BatchResponse {
  /// The number of messages that resulted in errors when sending.
  external num get failureCount;

  /// An array of responses, each corresponding to a message.
  external List<SendResponse> get responses;

  /// The number of messages that were successfully handed off for sending.
  external num get successCount;

  external factory BatchResponse({
    num failureCount,
    List<SendResponse> responses,
    num successCount,
  });
}

/// Interface representing the status of an individual message that was sent
/// as part of a batch request.
@JS()
@anonymous
abstract class SendResponse {
  /// An error, if the message was not handed off to FCM successfully.
  external FirebaseError get error;

  /// A unique message ID string, if the message was handed off to FCM for
  /// delivery.
  external String get messageId;

  /// A boolean indicating if the message was successfully handed off to FCM
  /// or not.
  ///
  /// When true, the messageId attribute is guaranteed to be set. When false,
  /// the error attribute is guaranteed to be set.
  external bool get success;

  external factory SendResponse({
    FirebaseError error,
    String messageId,
    bool success,
  });
}

/// Interface representing the server response from the legacy
/// sendToCondition() method.
@JS()
@anonymous
abstract class MessagingConditionResponse {
  /// The message ID for a successfully received request which FCM will attempt
  /// to deliver to all subscribed devices.
  external num get messageId;

  external factory MessagingConditionResponse({
    num messageId,
  });
}

/// Interface representing the server response from the sendToDeviceGroup()
/// method.
@JS()
@anonymous
abstract class MessagingDeviceGroupResponse {
  /// An array of registration tokens that failed to receive the message.
  external List<String> get failedRegistrationTokens;

  /// The number of messages that could not be processed and resulted in an error.
  external num get failureCount;

  /// The number of messages that could not be processed and resulted in an error.
  external num get successCount;

  external factory MessagingDeviceGroupResponse({
    List<String> failedRegistrationTokens,
    num failureCount,
    num successCount,
  });
}

/// Interface representing the status of a message sent to an individual device
/// via the FCM legacy APIs.
@JS()
@anonymous
abstract class MessagingDeviceResult {
  /// The canonical registration token for the client app that the message was
  /// processed and sent to.
  ///
  /// You should use this value as the registration token for future requests.
  /// Otherwise, future messages might be rejected.
  external String get canonicalRegistrationToken;

  /// The error that occurred when processing the message for the recipient.
  external FirebaseError get error;

  /// A unique ID for the successfully processed message.
  external String get messageId;

  external factory MessagingDeviceResult({
    String canonicalRegistrationToken,
    FirebaseError error,
    String messageId,
  });
}

/// Interface representing the server response from the legacy sendToDevice()
/// method.
@JS()
@anonymous
abstract class MessagingDevicesResponse {
  /// The number of results that contain a canonical registration token.
  ///
  /// A canonical registration token is the registration token corresponding
  /// to the last registration requested by the client app. This is the token
  /// that you should use when sending future messages to the device. You can
  /// access the canonical registration tokens within the results property.
  external num get canonicalRegistrationTokenCount;

  /// The number of messages that could not be processed and resulted in an
  /// error.
  external num get failureCount;

  /// The unique ID number identifying this multicast message.
  external num get multicastId;

  /// An array of [MessagingDeviceResult] objects representing the status of the
  /// processed messages.
  ///
  /// The objects are listed in the same order as in the request. That is, for
  /// each registration token in the request, its result has the same index in
  /// this array. If only a single registration token is provided, this array
  /// will contain a single object.
  external List<MessagingDeviceResult> get results;

  /// The number of messages that were successfully processed and sent.
  external num get successCount;

  external factory MessagingDevicesResponse({
    num canonicalRegistrationTokenCount,
    num failureCount,
    num multicastId,
    List<MessagingDeviceResult> results,
    num successCount,
  });
}

/// Interface representing the server response from the legacy sendToTopic()
/// method.
@JS()
@anonymous
abstract class MessagingTopicResponse {
  /// The message ID for a successfully received request which FCM will attempt
  /// to deliver to all subscribed devices.
  external num get messageId;

  external factory MessagingTopicResponse({
    num messageId,
  });
}

/// Interface representing the server response from the subscribeToTopic() and
/// admin.messaging.Messaging#unsubscribeFromTopic unsubscribeFromTopic()
/// methods.
@JS()
@anonymous
abstract class MessagingTopicManagementResponse {
  /// An array of errors corresponding to the provided registration token(s).
  ///
  /// The length of this array will be equal to failureCount.
  external List<FirebaseArrayIndexError> get errors;

  /// The number of registration tokens that could not be subscribed to the
  /// topic and resulted in an error.
  external num get failureCount;

  /// The number of registration tokens that were successfully subscribed to
  /// the topic.
  external num get successCount;

  external factory MessagingTopicManagementResponse({
    List<FirebaseArrayIndexError> errors,
    num failureCount,
    num successCount,
  });
}

// admin.database ================================================================

@JS()
@anonymous
abstract class DatabaseService {
  // Implementing call method breaks dart2js.
  // external Database call([App app]);

  /// Logs debugging information to the console.
  external enableLogging([dynamic loggerOrBool, bool persistent]);
  external ServerValues get ServerValue;
}

/// A placeholder value for auto-populating the current timestamp (time since
/// the Unix epoch, in milliseconds) as determined by the Firebase servers.
@JS()
@anonymous
abstract class ServerValues {
  external num get TIMESTAMP;
}

/// The Firebase Database interface.
///
/// Access via [FirebaseAdmin.database].
@JS()
@anonymous
abstract class Database {
  /// The app associated with this Database instance.
  external App get app;

  /// Disconnects from the server (all Database operations will be completed
  /// offline).
  external void goOffline();

  /// Reconnects to the server and synchronizes the offline Database state with
  /// the server state.
  external void goOnline();

  /// Returns a [Reference] representing the location in the Database
  /// corresponding to the provided [path]. If no path is provided, the
  /// Reference will point to the root of the Database.
  external Reference ref([String path]);

  /// Returns a Reference representing the location in the Database
  /// corresponding to the provided Firebase URL.
  external Reference refFromURL(String url);
}

/// A Reference represents a specific location in your [Database] and can be
/// used for reading or writing data to that Database location.
@JS()
@anonymous
abstract class Reference extends Query {
  /// The last part of this Reference's path.
  ///
  /// For example, "ada" is the key for `https://<DB>.firebaseio.com/users/ada`.
  /// The key of a root [Reference] is `null`.
  external String get key;

  /// The parent location of this Reference.
  ///
  /// The parent of a root Reference is `null`.
  external Reference get parent;

  /// The root `Reference` of the [Database].
  external Reference get root;

  /// Gets a `Reference` for the location at the specified relative [path].
  ///
  /// The relative [path] can either be a simple child name (for example, "ada")
  /// or a deeper slash-separated path (for example, "ada/name/first").
  external Reference child(String path);

  /// Returns an [OnDisconnect] object.
  ///
  /// For more information on how to use it see
  /// [Enabling Offline Capabilities in JavaScript](https://firebase.google.com/docs/database/web/offline-capabilities).
  external OnDisconnect onDisconnect();

  /// Generates a new child location using a unique key and returns its
  /// [Reference].
  ///
  /// This is the most common pattern for adding data to a collection of items.
  ///
  /// If you provide a [value] to `push()`, the value will be written to the
  /// generated location. If you don't pass a value, nothing will be written to
  /// the Database and the child will remain empty (but you can use the
  /// [Reference] elsewhere).
  ///
  /// The unique key generated by this method are ordered by the current time,
  /// so the resulting list of items will be chronologically sorted. The keys
  /// are also designed to be unguessable (they contain 72 random bits of
  /// entropy).
  external ThenableReference push([value, onComplete(JsError error)]);

  /// Removes the data at this Database location.
  ///
  /// Any data at child locations will also be deleted.
  ///
  /// The effect of the remove will be visible immediately and the corresponding
  /// event 'value' will be triggered. Synchronization of the remove to the
  /// Firebase servers will also be started, and the returned [Promise] will
  /// resolve when complete. If provided, the [onComplete] callback will be
  /// called asynchronously after synchronization has finished.
  external Promise remove([onComplete(JsError error)]);

  /// Writes data to this Database location.
  ///
  /// This will overwrite any data at this location and all child locations.
  ///
  /// The effect of the write will be visible immediately, and the corresponding
  /// events ("value", "child_added", etc.) will be triggered. Synchronization
  /// of the data to the Firebase servers will also be started, and the returned
  /// [Promise] will resolve when complete. If provided, the [onComplete]
  /// callback will be called asynchronously after synchronization has finished.
  ///
  /// Passing `null` for the new value is equivalent to calling [remove];
  /// namely, all data at this location and all child locations will be deleted.
  ///
  /// [set] will remove any priority stored at this location, so if priority is
  /// meant to be preserved, you need to use [setWithPriority] instead.
  ///
  /// Note that modifying data with [set] will cancel any pending transactions
  /// at that location, so extreme care should be taken if mixing [set] and
  /// [transaction] to modify the same data.
  ///
  /// A single [set] will generate a single "value" event at the location where
  /// the `set()` was performed.
  external Promise set(value, [onComplete(JsError error)]);

  /// Sets a priority for the data at this Database location.
  ///
  /// Applications need not use priority but can order collections by ordinary
  /// properties.
  ///
  /// See also:
  /// - [Sorting and filtering data](https://firebase.google.com/docs/database/web/lists-of-data#sorting_and_filtering_data)
  external Promise setPriority(priority, [onComplete(JsError error)]);

  /// Writes data the Database location. Like [set] but also specifies the
  /// [priority] for that data.
  ///
  /// Applications need not use priority but can order collections by ordinary
  /// properties.
  ///
  /// See also:
  /// - [Sorting and filtering data](https://firebase.google.com/docs/database/web/lists-of-data#sorting_and_filtering_data)
  external Promise setWithPriority(value, priority,
      [onComplete(JsError error)]);

  /// Atomically modifies the data at this location.
  ///
  /// Atomically modify the data at this location. Unlike a normal [set), which
  /// just overwrites the data regardless of its previous value, [transaction]
  /// is used to modify the existing value to a new value, ensuring there are no
  /// conflicts with other clients writing to the same location at the same time.
  ///
  /// To accomplish this, you pass transaction() an update function which is used
  /// to transform the current value into a new value. If another client writes to
  /// the location before your new value is successfully written, your update
  /// function will be called again with the new current value, and the write will
  /// be retried. This will happen repeatedly until your write succeeds without
  /// conflict or you abort the transaction by not returning a value from your
  /// update function.

  /// Note: Modifying data with [set] will cancel any pending transactions at that
  /// location, so extreme care should be taken if mixing set() and transaction()
  /// to update the same data.

  /// Note: When using transactions with Security and Firebase Rules in place, be
  /// aware that a client needs .read access in addition to .write access in order
  /// to perform a transaction. This is because the client-side nature of
  /// transactions requires the client to read the data in order to
  /// transactionally update it.
  external Promise transaction(transactionUpdate(snapshot),
      onComplete(error, bool committed, snapshot), bool applyLocally);

  /// Writes multiple values to the Database at once.
  ///
  /// The [values] argument contains multiple property-value pairs that will be
  /// written to the Database together. Each child property can either be a simple
  /// property (for example, "name") or a relative path (for example,
  /// "name/first") from the current location to the data to update.
  ///
  /// As opposed to the [set] method, [update] can be used to selectively update
  /// only the referenced properties at the current location (instead of replacing
  /// all the child properties at the current location).
  ///
  /// The effect of the write will be visible immediately, and the corresponding
  /// events ('value', 'child_added', etc.) will be triggered. Synchronization of
  /// the data to the Firebase servers will also be started, and the returned
  /// `Promise` will resolve when complete.
  ///
  /// If provided, the [onComplete] callback will be called asynchronously after
  /// synchronization has finished.
  ///
  /// A single [update] will generate a single "value" event at the location where
  /// the `update` was performed, regardless of how many children were modified.
  ///
  /// Note that modifying data with [update] will cancel any pending transactions
  /// at that location, so extreme care should be taken if mixing [update] and
  /// [transaction] to modify the same data.
  ///
  /// Passing `null` to [update] will remove the data at this location.
  external Promise update(values, [onComplete(JsError error)]);
}

@JS()
@anonymous
abstract class TransactionResult {
  bool get committed;
  DataSnapshot get snapshot;
}

@JS()
@anonymous
abstract class ThenableReference extends Reference implements Promise {}

/// Allows you to write or clear data when your client disconnects from the
/// [Database] server. These updates occur whether your client disconnects
/// cleanly or not, so you can rely on them to clean up data even if a
/// connection is dropped or a client crashes.
///
/// This class is most commonly used to manage presence in applications where it
/// is useful to detect how many clients are connected and when other clients
/// disconnect. See [Enabling Offline Capabilities in JavaScript](https://firebase.google.com/docs/database/web/offline-capabilities)
/// for more information.
///
/// To avoid problems when a connection is dropped before the requests can be
/// transferred to the Database server, these functions should be called before
/// any data is written.
///
/// Note that `onDisconnect` operations are only triggered once. If you want an
/// operation to occur each time a disconnect occurs, you'll need to
/// re-establish the onDisconnect operations each time you reconnect.
@JS()
@anonymous
abstract class OnDisconnect {
  /// Cancels all previously queued `onDisconnect()` set or update events for
  /// this location and all children.
  ///
  /// If a write has been queued for this location via a [set] or [update] at a
  /// parent location, the write at this location will be canceled, though all
  /// other siblings will still be written.
  ///
  /// Optional [onComplete] function that will be called when synchronization to
  /// the server has completed. The callback will be passed a single parameter:
  /// `null` for success, or a [JsError] object indicating a failure.
  external Promise cancel([onComplete(JsError error)]);

  /// Ensures the data at this location is deleted when the client is
  /// disconnected (due to closing the browser, navigating to a new page, or
  /// network issues).
  ///
  /// Optional [onComplete] function that will be called when synchronization to
  /// the server has completed. The callback will be passed a single parameter:
  /// `null` for success, or a [JsError] object indicating a failure.
  external Promise remove([onComplete(JsError error)]);

  /// Ensures the data at this location is set to the specified [value] when the
  /// client is disconnected (due to closing the browser, navigating to a new
  /// page, or network issues).
  ///
  /// [set] is especially useful for implementing "presence" systems, where a
  /// value should be changed or cleared when a user disconnects so that they
  /// appear "offline" to other users.
  ///
  /// Optional [onComplete] function that will be called when synchronization to
  /// the server has completed. The callback will be passed a single parameter:
  /// `null` for success, or a [JsError] object indicating a failure.
  ///
  /// See also:
  /// - [Enabling Offline Capabilities in JavaScript](https://firebase.google.com/docs/database/web/offline-capabilities)
  external Promise set(value, [onComplete(JsError error)]);

  /// Ensures the data at this location is set to the specified [value] and
  /// [priority] when the client is disconnected (due to closing the browser,
  /// navigating to a new page, or network issues).
  external Promise setWithPriority(value, priority,
      [onComplete(JsError error)]);

  /// Writes multiple [values] at this location when the client is disconnected
  /// (due to closing the browser, navigating to a new page, or network issues).
  ///
  /// The [values] argument contains multiple property-value pairs that will be
  /// written to the Database together. Each child property can either be a
  /// simple property (for example, "name") or a relative path (for example,
  /// "name/first") from the current location to the data to update.
  ///
  /// As opposed to the [set] method, [update] can be use to selectively update
  /// only the referenced properties at the current location (instead of
  /// replacing all the child properties at the current location).
  ///
  /// See [Reference.update] for examples of using the connected version of
  /// update.
  external Promise update(values, [onComplete(JsError error)]);
}

/// Sorts and filters the data at a [Database] location so only a subset of the
/// child data is included.
///
/// This can be used to order a collection of data by some attribute (for
/// example, height of dinosaurs) as well as to restrict a large list of items
/// (for example, chat messages) down to a number suitable for synchronizing to
/// the client. Queries are created by chaining together one or more of the
/// filter methods defined here.
///
/// Just as with a [Reference], you can receive data from a [Query] by using
/// the [on] method. You will only receive events and [DataSnapshot]s for the
/// subset of the data that matches your query.
///
/// See also:
///   - [Sorting and filtering data](https://firebase.google.com/docs/database/web/lists-of-data#sorting_and_filtering_data)
@JS()
@anonymous
abstract class Query {
  /// Returns a `Reference` to the [Query]'s location.
  external Reference get ref;

  /// Creates a [Query] with the specified ending point.
  ///
  /// Using [startAt], [endAt], and [equalTo] allows you to choose arbitrary
  /// starting and ending points for your queries.
  /// The ending point is inclusive, so children with exactly the specified
  /// value will be included in the query. The optional key argument can be used
  /// to further limit the range of the query. If it is specified, then children
  /// that have exactly the specified value must also have a key name less than
  /// or equal to the specified key.
  ///
  /// The [value] type depends on which `orderBy*()` function was used in this
  /// query. Specify a value that matches the `orderBy*()` type. When used in
  /// combination with [orderByKey], the value must be a `String`.
  ///
  /// Optional [key] is only allowed if ordering by priority and defines the
  /// child key to end at, among the children with the previously specified
  /// priority.
  external Query endAt(dynamic value, [String key]);

  /// Creates a [Query] that includes children that match the specified value.
  ///
  /// Using [startAt], [endAt], and [equalTo] allows you to choose arbitrary
  /// starting and ending points for your queries.
  ///
  /// The [value] type depends on which `orderBy*()` function was used in this
  /// query. Specify a value that matches the `orderBy*()` type. When used in
  /// combination with [orderByKey], the value must be a `String`.
  ///
  /// The optional [key] argument can be used to further limit the range of the
  /// query. If it is specified, then children that have exactly the specified
  /// value must also have exactly the specified key as their key name. This can
  /// be used to filter result sets with many matches for the same value.
  external Query equalTo(dynamic value, [String key]);

  /// Returns `true` if this and [other] query are equal.
  ///
  /// Returns whether or not the current and provided queries represent the same
  /// location, have the same query parameters, and are from the same instance
  /// of [App]. Equivalent queries share the same sort order, limits, and
  /// starting and ending points.
  ///
  /// Two [Reference] objects are equivalent if they represent the same location
  /// and are from the same instance of [App].
  external bool isEqual(Query other);

  /// Generates a new [Query] limited to the first specific number of children.
  ///
  /// This method is used to set a maximum number of children to be synced for a
  /// given callback. If we set a limit of 100, we will initially only receive
  /// up to 100 child_added events. If we have fewer than 100 messages stored in
  /// our [Database], a child_added event will fire for each message. However,
  /// if we have over 100 messages, we will only receive a child_added event for
  /// the first 100 ordered messages. As items change, we will receive
  /// child_removed events for each item that drops out of the active list so
  /// that the total number stays at 100.
  external Query limitToFirst(num limit);

  /// Generates a new [Query] limited to the last specific number of children.
  ///
  /// This method is used to set a maximum number of children to be synced for a
  /// given callback. If we set a limit of 100, we will initially only receive
  /// up to 100 child_added events. If we have fewer than 100 messages stored in
  /// our Database, a child_added event will fire for each message. However, if
  /// we have over 100 messages, we will only receive a child_added event for
  /// the last 100 ordered messages. As items change, we will receive
  /// child_removed events for each item that drops out of the active list so
  /// that the total number stays at 100.
  external Query limitToLast(num limit);

  /// Detaches a callback previously attached with [on].
  ///
  /// Note that if [on] was called multiple times with the same [eventType] and
  /// [callback], the callback will be called multiple times for each event, and
  /// [off] must be called multiple times to remove the callback. Calling [off]
  /// on a parent listener will not automatically remove listeners registered on
  /// child nodes, [off] must also be called on any child listeners to remove
  /// the callback.
  ///
  /// If a [callback] is not specified, all callbacks for the specified
  /// [eventType] will be removed. Similarly, if no [eventType] or [callback] is
  /// specified, all callbacks for the [Reference] will be removed.
  external void off([String eventType, callback, context]);

  /// Listens for data changes at a particular location.
  ///
  /// This is the primary way to read data from a [Database]. Your callback will
  /// be triggered for the initial data and again whenever the data changes.
  /// Use [off] to stop receiving updates.
  external void on(String eventType, callback,
      [cancelCallbackOrContext, context]);

  /// Listens for exactly one event of the specified [eventType], and then stops
  /// listening.
  ///
  /// This is equivalent to calling [on], and then calling [off] inside the
  /// callback function. See [on] for details on the event types.
  external Promise once(String eventType,
      [successCallback, failureCallbackOrContext, context]);

  /// Generates a new [Query] object ordered by the specified child key.
  ///
  /// Queries can only order by one key at a time. Calling [orderByChild]
  /// multiple times on the same query is an error.
  external Query orderByChild(String path);

  /// Generates a new [Query] object ordered by key.
  ///
  /// Sorts the results of a query by their (ascending) key values.
  ///
  /// See also:
  /// - [Sort data](https://firebase.google.com/docs/database/web/lists-of-data#sort_data)
  external Query orderByKey();

  /// Generates a new [Query] object ordered by priority.
  ///
  /// Applications need not use priority but can order collections by ordinary
  /// properties.
  ///
  /// See also:
  /// - [Sort data](https://firebase.google.com/docs/database/web/lists-of-data#sort_data)
  external Query orderByPriority();

  /// Generates a new [Query] object ordered by value.
  ///
  /// If the children of a query are all scalar values (string, number, or
  /// boolean), you can order the results by their (ascending) values.
  ///
  /// See also:
  /// - [Sort data](https://firebase.google.com/docs/database/web/lists-of-data#sort_data)
  external Query orderByValue();

  /// Creates a [Query] with the specified starting point.
  ///
  /// The starting point is inclusive, so children with exactly the specified
  /// [value] will be included in the query.
  ///
  /// The optional [key] argument can be used to further limit the range of the
  /// query. If it is specified, then children that have exactly the specified
  /// [value] must also have a `key` name greater than or equal to the specified
  /// [key].
  ///
  /// See also:
  /// - [Filtering data](https://firebase.google.com/docs/database/web/lists-of-data#filtering_data)
  external Query startAt(dynamic value, [String key]);

  /// Returns a JSON-serializable representation of this object.
  external dynamic toJSON();

  /// Gets the absolute URL for this location.
  ///
  /// Returned URL is ready to be put into a browser, curl command, or
  /// [Database.refFromURL] call. Since all of those expect the URL to be
  /// url-encoded, [toString] returns an encoded URL.
  ///
  /// Append '.json' to the returned URL when typed into a browser to download
  /// JSON-formatted data. If the location is secured (that is, not publicly
  /// readable), you will get a permission-denied error.
  external String toString();
}

/// Contains data from a Database location.
///
/// Any time you read data from the Database, you receive the data as a
/// [DataSnapshot]. A DataSnapshot is passed to the event callbacks you attach
/// with [Reference.on] or [Reference.once]. You can extract the contents of the
/// snapshot as a JavaScript object by calling the [val] method. Alternatively,
/// you can traverse into the snapshot by calling [child] to return child
/// snapshots (which you could then call [val] on).
///
/// A DataSnapshot is an efficiently generated, immutable copy of the data at a
/// Database location. It cannot be modified and will never change (to modify
/// data, you always call the [set] method on a [Reference] directly).
@JS()
@anonymous
abstract class DataSnapshot {
  /// The key (last part of the path) of the location of this DataSnapshot.
  ///
  /// The last token in a Database location is considered its key. For example,
  /// "ada" is the key for the `/users/ada/` node. Accessing the key on any
  /// DataSnapshot will return the key for the location that generated it.
  /// However, accessing the key on the root URL of a Database will return
  /// `null`.
  external String get key;

  /// The [Reference] for the location that generated this DataSnapshot.
  external Reference get ref;

  /// Gets another DataSnapshot for the location at the specified relative
  /// [path].
  ///
  /// Passing a relative path to the [child] method of a DataSnapshot returns
  /// another DataSnapshot for the location at the specified relative path. The
  /// relative [path] can either be a simple child name (for example, "ada") or
  /// a deeper, slash-separated path (for example, "ada/name/first"). If the
  /// child location has no data, an empty DataSnapshot (that is, a DataSnapshot
  /// whose value is `null`) is returned.
  external DataSnapshot child(String path);

  /// Returns `true` if this DataSnapshot contains any data.
  ///
  /// It is slightly more efficient than using `snapshot.val() != null`.
  external bool exists();

  /// Exports the entire contents of the DataSnapshot as a JavaScript object.
  ///
  /// The [exportVal] method is similar to [val], except priority information is
  /// included (if available), making it suitable for backing up your data.
  external dynamic exportVal();

  /// Enumerates the top-level children in this DataSnapshot.
  ///
  /// The [action] function is called for each child DataSnapshot. The callback
  /// can return `true` to cancel further enumeration.
  ///
  /// This method returns `true` if enumeration was canceled due to your
  /// callback returning true.
  ///
  /// Because of the way JavaScript objects work, the ordering of data in the
  /// JavaScript object returned by [val] is not guaranteed to match the
  /// ordering on the server nor the ordering of child_added events. That is
  /// where [forEach] comes in handy. It guarantees the children of a
  /// DataSnapshot will be iterated in their query order.
  ///
  /// If no explicit `orderBy*()` method is used, results are returned ordered
  /// by key (unless priorities are used, in which case, results are returned by
  /// priority).
  external bool forEach(bool action(DataSnapshot child));

  /// Gets the priority value of the data in this DataSnapshot.
  ///
  /// Applications need not use priority but can order collections by ordinary
  /// properties.
  ///
  /// See also:
  /// - [Sorting and filtering data](https://firebase.google.com/docs/database/web/lists-of-data#sorting_and_filtering_data)
  external dynamic getPriority();

  /// Returns `true` if the specified child [path] has (non-null) data.
  external bool hasChild(String path);

  /// Returns whether or not this DataSnapshot has any non-null child
  /// properties.
  ///
  /// You can use [hasChildren] to determine if a DataSnapshot has any children.
  /// If it does, you can enumerate them using [forEach]. If it doesn't, then
  /// either this snapshot contains a primitive value (which can be retrieved
  /// with [val]) or it is empty (in which case, [val] will return `null`).
  external bool hasChildren();

  /// Returns the number of child properties of this DataSnapshot.
  external num numChildren();

  /// Returns a JSON-serializable representation of this object.
  external dynamic toJSON();

  /// Extracts a JavaScript value from this DataSnapshot.
  ///
  /// Depending on the data in a DataSnapshot, the [val] method may return a
  /// scalar type (string, number, or boolean), an array, or an object. It may
  /// also return `null`, indicating that the DataSnapshot is empty (contains
  /// no data).
  external dynamic val();
}

// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:node_interop/util.dart';

import 'bindings.dart' as js show Auth;
import 'bindings.dart'
    show
        UserRecord,
        CreateUserRequest,
        UpdateUserRequest,
        ListUsersResult,
        DecodedIdToken;

export 'bindings.dart'
    show
        UserRecord,
        UserInfo,
        UserMetadata,
        CreateUserRequest,
        UpdateUserRequest,
        ListUsersResult,
        DecodedIdToken,
        FirebaseSignInInfo;

class Auth {
  Auth(this.nativeInstance);

  @protected
  final js.Auth nativeInstance;

  /// Creates a new Firebase custom token (JWT) that can be sent back to a client
  /// device to use to sign in with the client SDKs' signInWithCustomToken()
  /// methods.
  ///
  /// Returns a [Future] containing a custom token string for the provided [uid]
  /// and payload.
  Future<String> createCustomToken(String uid,
          [Map<String, String> developerClaims]) =>
      promiseToFuture(
          nativeInstance.createCustomToken(uid, jsify(developerClaims)));

  /// Creates a new user.
  Future<UserRecord> createUser(CreateUserRequest properties) =>
      promiseToFuture(nativeInstance.createUser(properties));

  /// Deletes an existing user.
  Future<void> deleteUser(String uid) =>
      promiseToFuture(nativeInstance.deleteUser(uid));

  /// Gets the user data for the user corresponding to a given [uid].
  Future<UserRecord> getUser(String uid) =>
      promiseToFuture(nativeInstance.getUser(uid));

  /// Gets the user data for the user corresponding to a given [email].
  Future<UserRecord> getUserByEmail(String email) =>
      promiseToFuture(nativeInstance.getUserByEmail(email));

  /// Gets the user data for the user corresponding to a given [phoneNumber].
  Future<UserRecord> getUserByPhoneNumber(String phoneNumber) =>
      promiseToFuture(nativeInstance.getUserByPhoneNumber(phoneNumber));

  /// Retrieves a list of users (single batch only) with a size of [maxResults]
  /// and starting from the offset as specified by [pageToken].
  ///
  /// This is used to retrieve all the users of a specified project in batches.
  Future<ListUsersResult> listUsers([num maxResults, String pageToken]) {
    if (pageToken != null && maxResults != null) {
      return promiseToFuture(nativeInstance.listUsers(maxResults, pageToken));
    } else if (maxResults != null) {
      return promiseToFuture(nativeInstance.listUsers(maxResults));
    } else {
      return promiseToFuture(nativeInstance.listUsers());
    }
  }

  /// Revokes all refresh tokens for an existing user.
  ///
  /// This API will update the user's [UserRecord.tokensValidAfterTime] to the
  /// current UTC. It is important that the server on which this is called has
  /// its clock set correctly and synchronized.
  ///
  /// While this will revoke all sessions for a specified user and disable any
  /// new ID tokens for existing sessions from getting minted, existing ID tokens
  /// may remain active until their natural expiration (one hour). To verify that
  /// ID tokens are revoked, use [Auth.verifyIdToken] where `checkRevoked` is set to
  /// `true`.
  Future<void> revokeRefreshTokens(String uid) =>
      promiseToFuture(nativeInstance.revokeRefreshTokens(uid));

  /// Sets additional developer claims on an existing user identified by the
  /// provided [uid], typically used to define user roles and levels of access.
  ///
  /// These claims should propagate to all devices where the user is already
  /// signed in (after token expiration or when token refresh is forced) and the
  /// next time the user signs in. If a reserved OIDC claim name is used
  /// (sub, iat, iss, etc), an error is thrown. They will be set on the
  /// authenticated user's ID token JWT.
  ///
  /// [customUserClaims] can be `null` in which case existing custom
  /// claims are deleted. Passing a custom claims payload larger than 1000 bytes
  /// will throw an error. Custom claims are added to the user's ID token which
  /// is transmitted on every authenticated request. For profile non-access
  /// related user attributes, use database or other separate storage systems.
  Future<void> setCustomUserClaims(
          String uid, Map<String, dynamic> customUserClaims) =>
      promiseToFuture(
          nativeInstance.setCustomUserClaims(uid, jsify(customUserClaims)));

  /// Updates an existing user.
  Future<UserRecord> updateUser(String uid, UpdateUserRequest properties) =>
      promiseToFuture(nativeInstance.updateUser(uid, properties));

  /// Verifies a Firebase ID token (JWT).
  ///
  /// If the token is valid, the returned [Future] is completed with an instance
  /// of [DecodedIdToken]; otherwise, the future is completed with an error.
  /// An optional flag can be passed to additionally check whether the ID token
  /// was revoked.
  Future<DecodedIdToken> verifyIdToken(String idToken, [bool checkRevoked]) {
    if (checkRevoked != null) {
      return promiseToFuture(
          nativeInstance.verifyIdToken(idToken, checkRevoked));
    } else {
      return promiseToFuture(nativeInstance.verifyIdToken(idToken));
    }
  }
}

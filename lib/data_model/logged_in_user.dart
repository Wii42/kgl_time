import 'dart:developer';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;

class LoggedInUser extends ChangeNotifier {
  firebase.User? _user;
  gapis.AuthClient? _client;
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: LoggedInUser.driveScopes);

  LoggedInUser([firebase.User? user, gapis.AuthClient? client]) {
    _user = user;
  }
  factory LoggedInUser.listenForUserChanges(
      [firebase.User? initialUser, gapis.AuthClient? client]) {
    return LoggedInUser(initialUser)..listenForUserChanges();
  }

  firebase.User? get user => _user;
  set user(firebase.User? userCredential) {
    _user = userCredential;
    notifyListeners();
  }

  gapis.AuthClient? get client => _client;
  set client(gapis.AuthClient? client) {
    _client = client;
    notifyListeners();
  }

  void listenForUserChanges() {
    firebase.FirebaseAuth.instance.userChanges().listen((firebase.User? user) {
      log('$user', name: 'LoggedInUser:listenForUserChanges');
      this.user = user;
      if (user == null) {
        _client = null;
      } else {updateDriveApi();}
    });
  }

  bool get isLoggedIn => user != null;
  bool get isLoggedOut => !isLoggedIn;

  Future<gapis.AuthClient?> getNewClient() async {
    await _googleSignIn.signInSilently();
    return _googleSignIn.authenticatedClient();
  }

  Future<void> updateDriveApi() async {
    _client = await getNewClient();
    notifyListeners();
    driveApi?.about.get($fields: 'user').then((value) {
      log('${value.user?.displayName} ${value.user?.emailAddress} ${value.user?.photoLink}', name: 'LoggedInUser:updateDriveApi');
    });
  }

  drive.DriveApi? get driveApi =>
      _client != null ? drive.DriveApi(_client!) : null;

  static List<String> driveScopes = [
    drive.DriveApi.driveAppdataScope,
  ];

  Future<firebase.UserCredential?> signInWithGoogle() async {
    try {
      if (Platform.isWindows || Platform.isLinux) {
        log('Google Sign In is not supported on Windows or Linux', name: 'LoggedInUser:signInWithGoogle', level: 900);
        return null;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final firebase.AuthCredential credential =
          firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      firebase.UserCredential user =
          await firebase.FirebaseAuth.instance.signInWithCredential(credential);
      return user;
    } on Exception catch (e) {
      // TODO
      log('exception->$e', name: 'LoggedInUser:signInWithGoogle', level: 1000);
      return null;
    }
  }

  Future<bool> signOut() async {
    try {
      await firebase.FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }
}

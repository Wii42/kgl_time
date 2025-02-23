import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:kgl_time/data_model/logged_in_user.dart';
import 'package:provider/provider.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoggedInUser>(builder: (context, user, child) {
      return (user.isLoggedOut)
          ? Center(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: IconButton(
                  iconSize: 40,
                  icon: FlutterLogo(),
                  onPressed: () async {
                    UserCredential? credentials = await user.signInWithGoogle();
                    if (credentials != null) {
                      print(credentials.user!.email);
                    }
                  },
                ),
              ),
            )
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 0, color: Colors.black54)),
                    child: Image.network(user.user!.photoURL.toString()),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(user.user!.displayName.toString()),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(user.user!.email.toString()),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        bool result = await user.signOut();
                        if (result) print('Logged out');
                      },
                      child: const Text('Logout'))
                ],
              ),
            );
    });
  }
}

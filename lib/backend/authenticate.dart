import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'database.dart' as database;

Future<Object> signup(String username, String email, String password) async {
  bool _usernameContainsSpecialChars() {
    const specialChars = " !@#\$\\{}[]\"';:%^&*()-+=`~?<>.,|/";
    for (var char in specialChars.split('')) {
      if (username.contains(char)) {
        return true;
      }
    }
    return false;
  }

  try {
    if (_usernameContainsSpecialChars()) {
      return 6;
    }
    if (username.length < 7) {
      return 4;
    }
    if (await database.isUsernameTaken(username)) {
      return 5;
    }

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    await FirebaseAuth.instance.currentUser!.updateDisplayName(username);
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    await database.addNewQuizAppUser();
    return FirebaseAuth.instance.currentUser!.uid;
  } on FirebaseAuthException catch (e) {
    String code = e.code;

    if (code == "email-already-in-use") {
      return 1;
    } else if (code == 'invalid-email') {
      return 2;
    } else if (code == 'weak-password') {
      return 3;
    } else if (code == 'operation-not-allowed') {
      print(e.toString());
      return 0;
    }
    return -1;
  }
}

Future<Object> login(String email, String password) async {
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    await database.fetchCurrentUserData();
    return FirebaseAuth.instance.currentUser!.uid;
  } on FirebaseAuthException catch (e) {
    final String code = e.code;

    if (code == 'invalid-email') {
      return {'e': 'Enter a valid email.'};
    } else if (code == 'user-disabled') {
      return {'e': 'Try again in a few minutes.'};
    } else if (code == 'user-not-found') {
      return {'e': 'No account found.'};
    } else if (code == 'wrong-password') {
      return {'e': 'Incorrect password.'};
    } else {
      print(e.toString());
      return {'e': 'Something went wrong.'};
    }
  }
}

Future<void> logout(context) async {
  await FirebaseAuth.instance.signOut();
  RestartWidget.restartApp(context);
}

User? get loggedInUser {
  return FirebaseAuth.instance.currentUser;
}

void refresh(context) {
  RestartWidget.restartApp(context);
}

class RestartWidget extends StatefulWidget {
  RestartWidget({required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

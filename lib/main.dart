import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './pages/homepage.dart';
import './pages/login_page.dart';
import 'backend/authenticate.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RestartWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {
  final Future _firebaseApp = Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "...",
          authDomain: "...",
          databaseURL:
              "...",
          projectId: "...",
          storageBucket: "...",
          messagingSenderId: "...",
          appId: "...",
          measurementId: "..."));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.red,
          navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.redAccent.shade100,
              indicatorColor: Colors.redAccent.shade200,
              labelTextStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              height: 60),
        ),
        home: FutureBuilder(
          future: _firebaseApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              return const Text("Something went wrong.");
            } else if (snapshot.hasData) {
              return FirebaseAuth.instance.currentUser == null
                  ? LoginPage()
                  : MyHomePage();
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}

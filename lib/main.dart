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
          apiKey: "AIzaSyCg_ISUUoo7NptZtwxb9yChc9XrXBNmr2s",
          authDomain: "quiz-app-web.firebaseapp.com",
          databaseURL:
              "https://quiz-app-web-default-rtdb.asia-southeast1.firebasedatabase.app",
          projectId: "quiz-app-web",
          storageBucket: "quiz-app-web.appspot.com",
          messagingSenderId: "352119065383",
          appId: "1:352119065383:web:e8f79b2d6a9a9188167702",
          measurementId: "G-6JQVTF86LX"));

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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pages/homepage.dart';

import '../backend/authenticate.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loggingIn = true;
  String _errorMessage = "";
  bool isLoading = false;
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _usernameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: loggingIn ? Text("Login Page") : Text("Sign up"),
        actions: [
          TextButton.icon(
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.onPrimary)),
              onPressed: () {
                setState(() {
                  loggingIn = !loggingIn;
                });
              },
              icon: const Icon(Icons.person_sharp),
              label: loggingIn ? Text("Sign up") : Text("Login"))
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(children: [
          Container(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  loggingIn
                      ? Container()
                      : TextFormField(
                          controller: _usernameCtrl,
                          decoration:
                              const InputDecoration(label: Text("Username")),
                          onFieldSubmitted: (_) {},
                          maxLength: 15,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        ),
                  // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(label: Text("Email")),
                    onFieldSubmitted: (_) {},
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: const InputDecoration(label: Text("Password")),
                    obscureText: true,
                    onFieldSubmitted: (_) {},
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  loggingIn
                      ? ElevatedButton(
                          onPressed: () async {
                            if (_passwordCtrl.text.isEmpty ||
                                _emailCtrl.text.isEmpty) {
                              setState(() {
                                _errorMessage = "No fields can be left empty.";
                              });
                            } else {
                              setState(() {
                                isLoading = true;
                              });
                              var returnValue = await login(
                                  _emailCtrl.text, _passwordCtrl.text);
                              setState(() {
                                isLoading = false;
                              });
                              if (returnValue is String) {
                                print(returnValue);
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: ((context) => MyHomePage())));
                              } else {
                                setState(() {
                                  returnValue as Map;
                                  _errorMessage = returnValue['e'];
                                });
                              }
                            }
                          },
                          child: const Text("Login"))
                      : ElevatedButton(
                          onPressed: () async {
                            if (_usernameCtrl.text.isEmpty ||
                                _passwordCtrl.text.isEmpty ||
                                _emailCtrl.text.isEmpty) {
                              setState(() {
                                _errorMessage = "No fields can be left empty.";
                              });
                            } else {
                              setState(() {
                                isLoading = true;
                              });
                              var returnValue = await signup(_usernameCtrl.text,
                                  _emailCtrl.text, _passwordCtrl.text);
                              setState(() {
                                isLoading = false;
                              });
                              if (returnValue is String) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => MyHomePage())));
                              } else {
                                if (returnValue == 0 || returnValue == -1) {
                                  setState(() {
                                    _errorMessage = "Something went wrong.";
                                  });
                                } else if (returnValue == 1) {
                                  setState(() {
                                    _errorMessage =
                                        "Account already exists for that email.";
                                  });
                                } else if (returnValue == 2) {
                                  setState(() {
                                    _errorMessage = "Enter a valid email.";
                                  });
                                } else if (returnValue == 3) {
                                  setState(() {
                                    _errorMessage = "Password is too weak.";
                                  });
                                } else if (returnValue == 4) {
                                  setState(() {
                                    _errorMessage = "Username is too short.";
                                  });
                                } else if (returnValue == 5) {
                                  setState(() {
                                    _errorMessage = "Username is taken.";
                                  });
                                } else if (returnValue == 6) {
                                  setState(() {
                                    _errorMessage =
                                        "Username cannot contain spaces or special characters.";
                                  });
                                }
                              }
                            }
                          },
                          child: const Text("Sign up")),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Text(
                    _errorMessage,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).errorColor),
                  )
                ],
              ),
            ),
          ),
          isLoading
              ? Container(
                  height: (MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.bottom) *
                      0.9,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    color: Theme.of(context)
                        .progressIndicatorTheme
                        .circularTrackColor,
                  ))
              : Container(),
        ]),
      ),
    );
  }
}

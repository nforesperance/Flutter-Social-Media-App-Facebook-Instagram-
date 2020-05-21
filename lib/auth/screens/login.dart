import 'package:buddiesgram/auth/utils/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool hidepass = true;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRepository>(context);
    return Scaffold(
      key: _key,
      body: Stack(
        children: <Widget>[
          Image.asset(
            "assets/images/login.jpg",
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Image.asset(
              "assets/images/lg.png",
              width: 280,
              height: 240,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 220.0),
            child: Container(
              alignment: Alignment.center,
              child: Center(
                child: Form(
                    key: _formKey,
                    child: ListView(children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white.withOpacity(0.4),
                          elevation: 0.0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: TextFormField(
                              controller: _email,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email",
                                icon: Icon(Icons.alternate_email),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  Pattern pattern =
                                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                  RegExp regex = new RegExp(pattern);
                                  if (!regex.hasMatch(value))
                                    return 'Please make sure your email address is valid';
                                  else
                                    return null;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white.withOpacity(0.4),
                          elevation: 0.0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: ListTile(
                              title: TextFormField(
                                controller: _password,
                                obscureText: hidepass,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Password",
                                  icon: Icon(Icons.lock_outline),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "The password field cannot be empty";
                                  } else if (value.length < 6) {
                                    return "the password has to be at least 6 characters long";
                                  }
                                  return null;
                                },
                              ),
                              trailing: IconButton(
                                  icon: Icon(Icons.remove_red_eye),
                                  onPressed: () {
                                    setState(() {
                                      hidepass = !hidepass;
                                    });
                                  }),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                        child: Material(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.blue,
                            elevation: 0.0,
                            child: MaterialButton(
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  if (!await user.signIn(
                                      _email.text, _password.text)) {
                                    //  _key.currentState.showSnackBar(SnackBar(content: Text("Sign in failed")));
                                    Fluttertoast.showToast(
                                        msg: "Sign In failed",
                                        gravity: ToastGravity.CENTER,
                                        fontSize: 24.0);
                                  }
                                }
                              },
                              minWidth: MediaQuery.of(context).size.width,
                              child: Text(
                                "Login",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18.0),
                              ),
                            )),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Forgot password",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                  onTap: () async {
                                    await user.signUpPage();
                                  },
                                  child: RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                      text: "Don't have and account?  ",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: "Sign Up",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 16),
                                    ),
                                  ])))),
                        ],
                      ),

                      // Expanded(child: Container()),
                      Divider(
                        color: Colors.white,
                      ),
                      Center(
                        child: Text(
                          "Other Sign In Options",
                          style: TextStyle(color: Colors.white, fontSize: 18.0),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                        child: Material(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.red,
                            elevation: 0.0,
                            child: MaterialButton(
                                onPressed: () async {
                                  await user.handleSignIn();
                                },
                                minWidth: MediaQuery.of(context).size.width,
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Image.asset(
                                        "assets/images/google.png",
                                        width: 30.0,
                                        height: 30.0,
                                      ),
                                    ),
                                    Text(
                                      "google",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18.0),
                                    ),
                                  ],
                                ))),
                      ),
                    ])),
              ),
            ),
          ),
          Visibility(
              visible: user.status == Status.Authenticating_Google ||
                      user.status == Status.Authenticating ??
                  true,
              child: Center(
                  child: Container(
                alignment: Alignment.center,
                color: Colors.white.withOpacity(0.6),
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.red.shade900),
                ),
              )))
        ],
      ),
    );
  }
}

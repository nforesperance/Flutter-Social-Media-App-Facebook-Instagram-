import 'package:buddiesgram/auth/utils/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _confirmpassword = TextEditingController();
  String gender;
  String groupvalue = "male";
  bool hide = true;
  bool hideconfirm = true;

  valueChanged(e) {
    setState(() {
      if (e == "male") {
        groupvalue = e;
        gender = e;
      } else if (e == "female") {
        groupvalue = e;
        gender = e;
      }
    });
  }

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
                      // username
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
                              controller: _username,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "username",
                                icon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "The username field cannot be empty";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),

                      //email
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

                      //password
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
                                obscureText: hide,
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
                                      hide = !hide;
                                    });
                                  }),
                            ),
                          ),
                        ),
                      ),

                      // confirm password
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
                                controller: _confirmpassword,
                                obscureText: hideconfirm,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Confirm Password",
                                  icon: Icon(Icons.lock_outline),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "The password field cannot be empty";
                                  } else if (value.length < 6) {
                                    return "the password has to be at least 6 characters long";
                                  } else if (value != _password.text) {
                                    return "Password donot Match";
                                  }

                                  return null;
                                },
                              ),
                              trailing: IconButton(
                                  icon: Icon(Icons.remove_red_eye),
                                  onPressed: () {
                                    setState(() {
                                      hideconfirm = !hideconfirm;
                                    });
                                  }),
                            ),
                          ),
                        ),
                      ),

                      //Gender

                      Padding(
                        padding: const EdgeInsets.only(right: 22.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: ListTile(
                                trailing: Radio(
                                    value: "male",
                                    groupValue: groupvalue,
                                    onChanged: (e) => valueChanged(e)),
                                title: Text(
                                  "Male",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                trailing: Radio(
                                  value: "female",
                                  groupValue: groupvalue,
                                  onChanged: (e) => valueChanged(e),
                                ),
                                title: Text(
                                  "Female",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //login button
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                        child: Material(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.red,
                            elevation: 0.0,
                            child: MaterialButton(
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                   user.register(_username.text, _email.text, _password.text, gender);
                                  // if (!await) {
                                  //   //  _key.currentState.showSnackBar(SnackBar(content: Text("Sign in failed")));
                                  //   Fluttertoast.showToast(
                                  //       msg: "Sign Un failed",
                                  //       gravity: ToastGravity.CENTER,
                                  //       fontSize: 24.0);
                                  // }
                                }
                              },
                              minWidth: MediaQuery.of(context).size.width,
                              child: Text(
                                "Sign Up",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18.0),
                              ),
                            )),
                      ),
                      Center(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                                onTap: () async {
                                  await user.signInPage();
                                },
                                child: RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                    text: "Already have and account?  ",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: "Sign In",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 16),
                                  ),
                                ])))),
                      ),

                      // Expanded(child: Container()),
                      Divider(
                        color: Colors.white,
                      ),
                    ])),
              ),
            ),
          ),
          Visibility(
              visible: user.status == Status.SigningUP??
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

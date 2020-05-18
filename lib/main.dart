import 'package:buddiesgram/auth/utils/firebase_auth.dart';
import 'package:buddiesgram/pages/CreateAccountPage.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/screens/login.dart';
import 'auth/screens/signup.dart';
import 'auth/screens/splash.dart';

void main()
{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Main(),
    );
  }
}

class Main extends StatelessWidget {
   @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserRepository.instance(auth: FirebaseAuth.instance),
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData
      (
        scaffoldBackgroundColor: Colors.black,
        dialogBackgroundColor: Colors.black,
        primarySwatch: Colors.grey,
        cardColor: Colors.white70,
        accentColor: Colors.black,
         unselectedWidgetColor: Colors.white,
         buttonColor: Colors.green,
      ),
        home: AuthHomePage(),
      ),
    );
  }
}

class AuthHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, UserRepository user, _) {
        switch (user.status) {
          case Status.Uninitialized:
            return SplashPage();
          case Status.Unauthenticated:
            return Login();
          case Status.Authenticating:
            return Login();
          case Status.Authenticating_Google:
            return Login();
          case Status.SignUp:
            return SignUp();
          case Status.Authenticated:
          // This condition is to avoid a case where the user was signed in
          // , but logoff and comes back straight to the home page
            return currentSignInUser==null?Login(): HomePage();
          case Status.SigningUP:
            return SignUp();
          case Status.Set_Username:
             return CreateAccountPage();
          default:
            return Login();
          break;
        }
      },
    );
  }
}

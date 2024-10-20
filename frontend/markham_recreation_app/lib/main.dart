import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart' if (dart.library.html) 'package:intl/intl_browser.dart';

import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:markham_recreation_app/login.dart';

void main() {
  var clientFactory = Client.new;

  // Start the app by fetching the system locale, then initializing date formatting
  //   and running the app with the client 
  findSystemLocale().whenComplete(() {
    initializeDateFormatting().then((_) {
      runWithClient(() {
        runApp(const MyApp());
      }, clientFactory);
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Setup homepage using data from global file
    return MaterialApp(
      title: globals.title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: globals.primaryColor),
        useMaterial3: true,
      ),
      home: const LandingPage(title: globals.title),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key, required this.title});

  final String title;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    if (globals.loggedIn) {
      // If the user is logged in alreadu, display the homepage
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(widget.title, style: const TextStyle(color: globals.secondaryColor)),
          iconTheme: const IconThemeData(color: globals.secondaryColor),
        ),
        drawer: drawer.drawer(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Image(
                image: AssetImage('lib/camp.png'),
                width: 200,
              ),
              const Text(
                'Please select a page from the navigation.',
              ),
              Padding(
                // pad bottom 25% of the screen
                padding: EdgeInsets.fromLTRB(0, 0, 0, max(MediaQuery.of(context).size.height * 0.25 - 150, 0)),
                child: const Text(''),
              ),
            ],
          ),
        ),
      );
    } else {
      // If the user is not logged in, display the login page
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(widget.title, style: const TextStyle(color: globals.secondaryColor)),
          iconTheme: const IconThemeData(color: globals.secondaryColor),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Image(
                image: AssetImage('lib/camp.png'),
                width: 180,
              ),
              ElevatedButton(
                onPressed: () {
                  // When the login button is pressed, navigate to the login page, then refresh the page
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Login())).then((_) {
                    setState(() {});
                  });
                },
                child: const Text('Login'),
              ),
              Padding(
                // pad bottom 25% of the screen
                padding: EdgeInsets.fromLTRB(0, 0, 0, max(MediaQuery.of(context).size.height * 0.25 - 150, 0)),
                child: const Text(''),
              ),
            ],
          ),
        ),
      );
    }
  }
}

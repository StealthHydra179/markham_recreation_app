import 'package:flutter/material.dart';
import 'package:http/http.dart';
// import 'package:http/browser_client.dart';

import 'package:markham_recreation_app/globals.dart' as globals;
import 'package:markham_recreation_app/drawer.dart' as drawer;
import 'package:intl/intl_standalone.dart' if (dart.library.html) 'package:intl/intl_browser.dart';
import 'package:markham_recreation_app/login.dart';

void main() {
  var clientFactory = Client.new;

  
  WidgetsFlutterBinding.ensureInitialized();

  globals.fetchcamp(0).whenComplete(() {
    findSystemLocale().whenComplete(() {
      runWithClient(() => runApp(const MyApp()), clientFactory);
    });
  });
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markham Recreation Summer camp',
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<LandingPage> createState() => _LandingPageState();

  // static void restartApp(BuildContext context) {
  //   _LandingPageState? state = context.findAncestorStateOfType<_LandingPageState>();
  //   print(state);
  //   // print(context.)
  //   state?.restartApp();
  //   print('Restarting app');
  //   print(context.findAncestorStateOfType<_LandingPageState>()?.toString());
  //   print(context.toString());
  // }
}

class _LandingPageState extends State<LandingPage> {
  // void restartApp() {
  //   //log
  //   print('Restarting app');
  //   setState(() {});
  // }


  @override
  Widget build(BuildContext context) {
    if (globals.loggedIn) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
              const Text(
                'Please select a page from the navigation.',
              ),
              // Text(
              //   '$_counter',
              //   style: Theme.of(context).textTheme.headlineMedium,
              // ),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _incrementCounter,
        //   tooltip: 'Increment',
        //   child: const Icon(Icons.add),
        // ),
      );
    } else {
      //button redirect to login page
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(widget.title, style: const TextStyle(color: globals.secondaryColor)),
          iconTheme: const IconThemeData(color: globals.secondaryColor),
        ),
        // drawer: drawer.drawer(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Please login to access the app.',
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Login())).then((_) {setState(() {});});
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }
  }
}

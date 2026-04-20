import 'package:flutter/material.dart';
import 'psychiatrist_dashboard/dashboard_screen.dart';
import 'auth/login_screen.dart';
import 'auth/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateRoute: (settings) {
        // Centralized route guard: require auth for /psy_dashboard
        if (settings.name == '/psy_dashboard') {
          if (AuthService.instance.isLoggedIn.value) {
            return MaterialPageRoute(builder: (_) => const PsychiatristDashboardScreen(), settings: settings);
          } else {
            return MaterialPageRoute(builder: (_) => LoginScreen(redirectTo: '/psy_dashboard'), settings: settings);
          }
        }

        if (settings.name == '/login') {
          final args = settings.arguments;
          String? redirect;
          if (args is String) redirect = args;
          return MaterialPageRoute(builder: (_) => LoginScreen(redirectTo: redirect), settings: settings);
        }

        // fallback to home
        return MaterialPageRoute(builder: (_) => const MyHomePage(title: 'Flutter Demo Home Page'), settings: settings);
      },
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('NUST Campus Health', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: AuthService.instance.isLoggedIn,
              builder: (context, loggedIn, _) {
                return ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: const Text('Psychiatrist Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    if (loggedIn) {
                      Navigator.pushNamed(context, '/psy_dashboard');
                    } else {
                      Navigator.pushNamed(context, '/login', arguments: '/psy_dashboard');
                    }
                  },
                );
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: AuthService.instance.isLoggedIn,
              builder: (context, loggedIn, _) {
                return ListTile(
                  leading: Icon(loggedIn ? Icons.logout : Icons.login),
                  title: Text(loggedIn ? 'Logout' : 'Login'),
                  onTap: () async {
                    Navigator.pop(context);
                    if (loggedIn) {
                      await AuthService.instance.logout();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out')));
                    } else {
                      Navigator.pushNamed(context, '/login');
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

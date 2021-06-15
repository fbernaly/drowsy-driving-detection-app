import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'screens/home_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.teal,
      ),
      home: const HomeScreen(title: 'Drowsy Driving Detection'),
    );
  }
}

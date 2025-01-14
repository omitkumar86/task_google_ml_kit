
import 'package:flutter/material.dart';
import 'package:task_google_ml_kit/view/screen/capture_image_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CaptureImageScreen(),
    );
  }
}


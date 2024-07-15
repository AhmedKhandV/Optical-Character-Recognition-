import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras= await availableCameras();
  final cameraone=cameras.first;

  runApp(MaterialApp(
    home: HomeScreen(camera: cameraone),
  ));
}

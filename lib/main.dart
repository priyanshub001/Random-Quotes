import 'package:flutter/material.dart';
import 'package:random_quotes/main_shell.dart';
import 'home_page.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainShell(),
    ),
  );
}
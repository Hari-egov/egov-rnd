import 'package:dummy2/digit_search_dropdown_screen.dart';
import 'package:dummy2/digit_text_form_screen.dart';
import 'package:dummy2/home.dart';
import 'package:flutter/material.dart';
import 'package:digit_components/theme/digit_theme.dart';
import 'package:digit_components/digit_components.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      theme: DigitTheme.instance.mobileTheme,
      debugShowCheckedModeBanner: false,
     // home:  DigitTextScreen(),
     
     // now for DigitSearchDropDownScreen
     home: const DigitSearchDropDownScreen(),
    );
  }
}

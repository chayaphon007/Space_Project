import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/research_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (context) => ResearchProvider()..fetchData("โครงการวิจัยอวกาศ"),
        ), // ✅ โหลดข้อมูลตอนเริ่มแอป
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Research',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black, // ทำให้ AppBar เป็นสีดำ
          foregroundColor: Colors.white, // ทำให้ข้อความเป็นสีขาว
        ),
      ),
      home: HomeScreen(category: "โครงการวิจัยอวกาศ"),
    );
  }
}

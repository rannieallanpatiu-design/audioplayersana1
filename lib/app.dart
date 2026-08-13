import 'package:flutter/cupertino.dart';
import 'screens/home_screen.dart';

class LiquidMusicApp extends StatelessWidget {
  const LiquidMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Liquid Music',
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFFFF5FA2),
        scaffoldBackgroundColor: Color(0xFF0B0B1E),
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(color: CupertinoColors.white),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

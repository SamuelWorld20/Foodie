import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:foodie/pages/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
        const Duration(seconds: 10),
        () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomePage())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/splash_screen.jpg'),
              fit: BoxFit.cover),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SpinKitWave(
                color: Color(0xffDD7B77),
                size: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

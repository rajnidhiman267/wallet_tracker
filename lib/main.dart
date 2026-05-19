import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/core/notification/notification_service.dart';
import 'package:tracker_app/core/routes/app_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      routerConfig: AppRouter.router,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_app/core/di/di.dart';
import 'package:tracker_app/core/notification/notification_service.dart';
import 'package:tracker_app/core/routes/app_route.dart';
import 'package:tracker_app/features/home/presentation/bloc/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initDependencies();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      // ✅ provide at the very top
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Expense Tracker',
            routerConfig: AppRouter.router,
            themeMode: themeMode, // ✅ drives light/dark switch
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.light(
                surface: Colors.grey.shade100,
                primary: const Color(0xFF00B2E7),
                secondary: const Color(0xFFE064F7),
                tertiary: const Color(0xFFFF8D6C),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00B2E7),
                secondary: Color(0xFFE064F7),
                tertiary: Color(0xFFFF8D6C),
              ),
            ),
          );
        },
      ),
    );
  }
}
